import Foundation
import Domain
import Utilities
import WhisperKit
import os

#if canImport(AVFoundation)
import AVFoundation
#endif


/// On-device speech-to-text using WhisperKit.
///
/// Records audio via `AVAudioRecorder` (reliable on both device and Simulator),
/// then resamples to 16 kHz and passes the samples to WhisperKit for transcription.
/// WhisperKit's built-in `AudioProcessor` is not used for recording because it
/// crashes on the iOS Simulator during audio device reconfiguration.
public final class WhisperVoiceInputService: VoiceInputServiceProtocol, @unchecked Sendable {

    // MARK: - State

    public private(set) var state: VoiceTranscriptionState = .idle
    public private(set) var modelStatus: VoiceModelStatus = .notDownloaded
    public private(set) var isMicrophonePermissionGranted: Bool = false

    // MARK: - Private

    private var whisperKit: WhisperKit?
    private let modelVariant: String
    private let logger = CBTLogger.logger(for: .voiceInput)

    /// AVAudioRecorder-based capture
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("whisper_recording.wav")
    }

    // MARK: - Init

    public nonisolated init(modelVariant: String = "base") {
        self.modelVariant = modelVariant
    }

    // MARK: - Model Preparation

    public func prepareModel() async throws {
        guard modelStatus != .ready else { return }

        logger.info("Preparing WhisperKit model: \(modelVariant)")
        state = .preparing
        modelStatus = .downloading(progress: 0.0)

        do {
            let kit = try await WhisperKit(model: modelVariant)

            // WhisperKit init downloads model files but may not fully load them.
            // Explicitly load models + tokenizer so they're ready before first transcription.
            logger.info("[MODEL] Post-init modelState=\(String(describing: kit.modelState))")

            try await kit.loadModels()
            logger.info("[MODEL] Post-loadModels modelState=\(String(describing: kit.modelState))")

            // Ensure the tokenizer is loaded — without it, token IDs can't be decoded to text
            try await kit.loadTokenizerIfNeeded()
            logger.info("[MODEL] Post-loadTokenizer tokenizer=\(kit.tokenizer == nil ? "nil" : "loaded")")

            whisperKit = kit

            // --- Model diagnostics ---
            logger.info("[MODEL] modelVariant=\(String(describing: kit.modelVariant))")
            logger.info("[MODEL] modelFolder=\(kit.modelFolder?.path ?? "nil")")
            logger.info("[MODEL] featureExtractor=\(type(of: kit.featureExtractor))")
            logger.info("[MODEL] audioEncoder=\(type(of: kit.audioEncoder))")
            logger.info("[MODEL] textDecoder=\(type(of: kit.textDecoder))")
            logger.info("[MODEL] isRunningOnSimulator=\(WhisperKit.isRunningOnSimulator)")
            // --- End model diagnostics ---

            modelStatus = .ready
            state = .idle
            logger.info("WhisperKit model ready")
        } catch {
            modelStatus = .error(error.localizedDescription)
            state = .error(error.localizedDescription)
            logger.error("WhisperKit model load failed: \(error.localizedDescription)")
            throw VoiceInputError.modelLoadFailed(error.localizedDescription)
        }
    }

    // MARK: - Recording

    public func startRecording() async throws {
        #if canImport(AVFoundation) && !os(macOS)
        guard isMicrophonePermissionGranted else {
            throw VoiceInputError.permissionDenied
        }

        if modelStatus != .ready {
            try await prepareModel()
        }

        logger.debug("Starting audio capture via AVAudioRecorder")

        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true)

        // Record as 16-bit PCM at 48 kHz — the Simulator's native hardware rate.
        // Recording at the native rate avoids real-time resampling artifacts on the
        // Simulator. WhisperKit's transcribe(audioPath:) handles 48→16 kHz conversion
        // internally with proper filtering.
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 48000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]

        let rec = try AVAudioRecorder(url: recordingURL, settings: settings)
        guard rec.record() else {
            throw VoiceInputError.recordingFailed("AVAudioRecorder.record() returned false")
        }
        recorder = rec
        state = .recording
        logger.info("Audio capture started (AVAudioRecorder, 48 kHz)")
        #else
        throw VoiceInputError.recordingFailed("Audio recording not available on this platform")
        #endif
    }

    public func stopRecording() async throws -> String {
        #if canImport(AVFoundation) && !os(macOS)
        logger.debug("Stopping audio capture")

        guard let rec = recorder else {
            state = .error("No active recorder")
            throw VoiceInputError.recordingFailed("No active recorder")
        }

        rec.stop()
        recorder = nil
        state = .transcribing

        // Quick check: does the file exist and have content?
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: recordingURL.path)[.size] as? Int) ?? 0
        logger.info("[AUDIO] WAV file: \(fileSize) bytes")
        guard fileSize > 44 else { // 44 = WAV header only, no audio data
            state = .idle
            logger.error("[AUDIO] WAV file is empty (header only)")
            return ""
        }

        // Read file to log audio diagnostics (but WhisperKit will read it independently)
        do {
            let file = try AVAudioFile(forReading: recordingURL)
            let frameCount = AVAudioFrameCount(file.length)
            let sr = file.processingFormat.sampleRate
            let ch = file.processingFormat.channelCount
            let duration = Double(frameCount) / sr
            logger.info("[AUDIO] format: \(Int(sr)) Hz, \(ch) ch, \(frameCount) frames (\(String(format: "%.1f", duration))s)")

            if let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) {
                try file.read(into: buffer)
                if let floatData = buffer.floatChannelData?[0] {
                    let samples = UnsafeBufferPointer(start: floatData, count: Int(buffer.frameLength))
                    let absMax = samples.map { abs($0) }.max() ?? 0
                    let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(samples.count))
                    logger.info("[AUDIO] absMax=\(String(format: "%.4f", absMax)) rms=\(String(format: "%.6f", rms))")
                }
            }
        } catch {
            logger.error("[AUDIO] Could not read WAV for diagnostics: \(error.localizedDescription)")
        }

        guard let whisperKit else {
            state = .error("Model not loaded")
            throw VoiceInputError.modelLoadFailed("WhisperKit not initialised")
        }

        // Log model state before transcription
        logger.info("[PRE-TRANSCRIBE] modelState=\(String(describing: whisperKit.modelState))")
        logger.info("[PRE-TRANSCRIBE] tokenizer=\(whisperKit.tokenizer == nil ? "nil" : "loaded")")

        do {
            let signpostState = CBTSignpost.begin("Transcribe")

            let options = DecodingOptions(
                language: "en",
                temperature: 0.0,
                temperatureFallbackCount: 3
            )

            // Use file-based transcription — let WhisperKit handle all audio
            // loading, resampling, and preprocessing internally.
            logger.info("[TRANSCRIBE] Calling transcribe(audioPath:) with file-based input")
            let results = try await whisperKit.transcribe(
                audioPath: recordingURL.path,
                decodeOptions: options
            )

            CBTSignpost.end("Transcribe", signpostState)

            let text = results.map(\.text).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            state = .result(text)
            logger.info("Transcription complete (\(results.count) segments): \(text.prefix(120))...")

            // Log per-segment details
            for (i, result) in results.enumerated() {
                logger.info("[DIAG] result[\(i)]: lang=\(result.language) segments=\(result.segments.count) text='\(result.text.prefix(80))'")
                for (j, seg) in result.segments.enumerated() {
                    logger.info("[DIAG]   seg[\(j)]: avgLogProb=\(String(format: "%.3f", seg.avgLogprob)) noSpeechProb=\(String(format: "%.3f", seg.noSpeechProb)) compression=\(String(format: "%.2f", seg.compressionRatio)) text='\(seg.text.prefix(60))'")
                }
            }

            // Log timings
            let timings = results.first?.timings
            logger.info("[TIMINGS] audioLoading=\(String(format: "%.2f", timings?.audioLoading ?? 0))s encoding=\(String(format: "%.2f", timings?.encoding ?? 0))s decoding=\(String(format: "%.2f", timings?.decodingLoop ?? 0))s")

            return text
        } catch {
            state = .error(error.localizedDescription)
            logger.error("Transcription failed: \(error.localizedDescription)")
            throw VoiceInputError.transcriptionFailed(error.localizedDescription)
        }
        #else
        throw VoiceInputError.recordingFailed("Audio recording not available on this platform")
        #endif
    }

    public func cancelRecording() {
        logger.debug("Cancelling recording")
        #if canImport(AVFoundation) && !os(macOS)
        recorder?.stop()
        recorder = nil
        #endif
        state = .idle
    }

    // MARK: - Permissions

    public func requestMicrophonePermission() async -> Bool {
        #if canImport(AVFoundation) && !os(macOS)
        logger.debug("Requesting microphone permission")
        let granted: Bool
        if #available(iOS 17.0, *) {
            granted = await AVAudioApplication.requestRecordPermission()
        } else {
            granted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            }
        }
        isMicrophonePermissionGranted = granted
        logger.info("Microphone permission: \(granted ? "granted" : "denied")")
        return granted
        #else
        return false
        #endif
    }
}
