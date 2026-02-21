import Foundation
import Domain
import Utilities
import WhisperKit

#if canImport(AVFoundation)
import AVFoundation
#endif

/// On-device speech-to-text using WhisperKit.
///
/// Captures audio via `AVAudioEngine` at 16 kHz mono, accumulates samples
/// in memory, and transcribes on stop. No audio files are persisted.
public final class WhisperVoiceInputService: VoiceInputServiceProtocol, @unchecked Sendable {

    // MARK: - State

    public private(set) var state: VoiceTranscriptionState = .idle
    public private(set) var modelStatus: VoiceModelStatus = .notDownloaded
    public private(set) var isMicrophonePermissionGranted: Bool = false

    // MARK: - Private

    private var whisperKit: WhisperKit?
    private let modelVariant: String
    private let logger = CBTLogger.logger(for: .voiceInput)

    #if canImport(AVFoundation)
    private var audioEngine: AVAudioEngine?
    #endif
    private var audioSamples: [Float] = []

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
            whisperKit = kit
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

        logger.debug("Starting audio capture")
        audioSamples = []

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Target 16kHz mono for Whisper
        guard let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        ) else {
            throw VoiceInputError.recordingFailed("Cannot create target audio format")
        }

        guard let converter = AVAudioConverter(from: recordingFormat, to: targetFormat) else {
            throw VoiceInputError.recordingFailed("Cannot create audio converter")
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self else { return }

            let frameCount = AVAudioFrameCount(
                Double(buffer.frameLength) * 16000 / recordingFormat.sampleRate
            )
            guard frameCount > 0 else { return }

            guard let convertedBuffer = AVAudioPCMBuffer(
                pcmFormat: targetFormat,
                frameCapacity: frameCount
            ) else { return }

            var error: NSError?
            converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            if let channelData = convertedBuffer.floatChannelData?[0] {
                let samples = Array(UnsafeBufferPointer(
                    start: channelData,
                    count: Int(convertedBuffer.frameLength)
                ))
                self.audioSamples.append(contentsOf: samples)
            }
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            try engine.start()
        } catch {
            throw VoiceInputError.recordingFailed(error.localizedDescription)
        }

        audioEngine = engine
        state = .recording
        logger.info("Audio capture started")
        #else
        throw VoiceInputError.recordingFailed("Audio recording not available on this platform")
        #endif
    }

    public func stopRecording() async throws -> String {
        #if canImport(AVFoundation) && !os(macOS)
        logger.debug("Stopping audio capture")

        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        state = .transcribing

        guard !audioSamples.isEmpty else {
            state = .idle
            return ""
        }

        guard let whisperKit else {
            state = .error("Model not loaded")
            throw VoiceInputError.modelLoadFailed("WhisperKit not initialised")
        }

        do {
            let results = try await whisperKit.transcribe(audioArray: audioSamples)
            let text = results.map(\.text).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            audioSamples = []
            state = .result(text)
            logger.info("Transcription complete: \(text.prefix(50))...")
            return text
        } catch {
            audioSamples = []
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
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        #endif
        audioSamples = []
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
