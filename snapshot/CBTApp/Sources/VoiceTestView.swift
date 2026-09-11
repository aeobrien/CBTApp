import SwiftUI
import Domain
import Services
import Features
import DesignSystem
import Utilities
import AVFoundation
@preconcurrency import WhisperKit

/// Test harness for Phase 11 voice input.
struct VoiceTestView: View {
    @State private var voiceService = WhisperVoiceInputService()
    @State private var testText = ""
    @State private var appendText = "Existing text here"
    @State private var statusMessage = "Ready"

    // Audition state
    @State private var isRecordingAudition = false
    @State private var auditionStatus = "Tap Record to capture audio"
    @State private var audioPlayer: AVAudioPlayer?
    @State private var auditionSampleCount = 0
    @State private var auditionPeak: Float = 0
    @State private var auditionRMS: Float = 0
    @State private var savedWavURL: URL?
    @State private var transcribeResult = ""

    var body: some View {
        List {
            Section("Model Status") {
                LabeledContent("Status", value: modelStatusText)
                Button("Prepare Model") {
                    Task {
                        statusMessage = "Loading model..."
                        do {
                            try await voiceService.prepareModel()
                            statusMessage = "Model ready"
                        } catch {
                            statusMessage = "Error: \(error.localizedDescription)"
                        }
                    }
                }
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Microphone Permission") {
                LabeledContent("Granted", value: voiceService.isMicrophonePermissionGranted ? "Yes" : "No")
                Button("Request Permission") {
                    Task {
                        let granted = await voiceService.requestMicrophonePermission()
                        statusMessage = granted ? "Permission granted" : "Permission denied"
                    }
                }
            }

            // MARK: - Audio Audition
            Section("Audio Audition") {
                Text("Record and play back to verify mic input")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Button(isRecordingAudition ? "Stop" : "Record") {
                        Task { await toggleAuditionRecording() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isRecordingAudition ? .red : .blue)

                    if savedWavURL != nil {
                        Button("Play") {
                            playAudition()
                        }
                        .buttonStyle(.bordered)

                        Button("Transcribe") {
                            Task { await transcribeAuditionFile() }
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                }

                Text(auditionStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if auditionSampleCount > 0 {
                    LabeledContent("Samples", value: "\(auditionSampleCount) (\(String(format: "%.1f", Double(auditionSampleCount) / 48000))s)")
                    LabeledContent("Peak", value: String(format: "%.4f", auditionPeak))
                    LabeledContent("RMS", value: String(format: "%.6f", auditionRMS))
                }

                if !transcribeResult.isEmpty {
                    LabeledContent("Transcription", value: transcribeResult)
                        .font(.body)
                }
            }

            Section("Voice Input — Empty Field") {
                TextField("Speak into this field...", text: $testText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .voiceInput(text: $testText, voiceService: voiceService)
            }

            Section("Voice Input — Append Mode") {
                TextField("Has existing text...", text: $appendText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .voiceInput(text: $appendText, voiceService: voiceService)
            }

            Section("Post-Processor Test") {
                let samples = [
                    ("hello world", TranscriptionPostProcessor.process("hello world")),
                    ("  spaces  ", TranscriptionPostProcessor.process("  spaces  ")),
                    ("already done.", TranscriptionPostProcessor.process("already done.")),
                    ("question?", TranscriptionPostProcessor.process("question?")),
                    ("", TranscriptionPostProcessor.process(""))
                ]
                ForEach(samples, id: \.0) { input, output in
                    LabeledContent("\"\(input)\"", value: "\"\(output)\"")
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Voice Input Test")
    }

    private var modelStatusText: String {
        switch voiceService.modelStatus {
        case .notDownloaded: return "Not downloaded"
        case .downloading(let progress): return "Downloading \(Int(progress * 100))%"
        case .ready: return "Ready"
        case .error(let msg): return "Error: \(msg)"
        }
    }

    // MARK: - Audition Recording

    /// Standalone audio capture using AVAudioRecorder (records to a file).
    /// AVAudioEngine crashes on the iOS Simulator when accessing inputNode
    /// during audio device reconfiguration, so we use the higher-level API.
    @State private var auditionRecorder: AVAudioRecorder?

    private func toggleAuditionRecording() async {
        if isRecordingAudition {
            stopAuditionRecording()
        } else {
            await startAuditionRecording()
        }
    }

    private func startAuditionRecording() async {
        auditionStatus = "Setting up audio session..."

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            auditionStatus = "Audio session error: \(error.localizedDescription)"
            return
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("audition.wav")

        // Record as 16-bit PCM at 48 kHz (the simulator's native rate)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 48000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
            guard recorder.record() else {
                auditionStatus = "AVAudioRecorder.record() returned false"
                return
            }
            auditionRecorder = recorder
            savedWavURL = url
            isRecordingAudition = true
            auditionStatus = "Recording at 48000 Hz... speak now"
        } catch {
            auditionStatus = "Recorder error: \(error.localizedDescription)"
        }
    }

    private func stopAuditionRecording() {
        guard let recorder = auditionRecorder else { return }
        recorder.stop()
        auditionRecorder = nil
        isRecordingAudition = false

        guard let url = savedWavURL else {
            auditionStatus = "No file saved"
            return
        }

        // Read the WAV file back to compute diagnostics
        do {
            let file = try AVAudioFile(forReading: url)
            let frameCount = AVAudioFrameCount(file.length)
            guard frameCount > 0,
                  let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
                auditionStatus = "No samples captured"
                return
            }
            try file.read(into: buffer)

            let sampleRate = file.processingFormat.sampleRate
            let count = Int(buffer.frameLength)
            auditionSampleCount = count

            // Extract float samples for analysis
            if let floatData = buffer.floatChannelData?[0] {
                let samples = Array(UnsafeBufferPointer(start: floatData, count: count))
                let peak = samples.map { abs($0) }.max() ?? 0
                let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(samples.count))
                auditionPeak = peak
                auditionRMS = rms

                let duration = Double(count) / sampleRate
                auditionStatus = "Captured \(String(format: "%.1f", duration))s — tap Play to listen"
            } else {
                auditionStatus = "Could not read float samples"
            }
        } catch {
            auditionStatus = "Read error: \(error.localizedDescription)"
        }
    }

    /// Transcribe the audition WAV file directly through WhisperKit,
    /// bypassing our WhisperVoiceInputService entirely.
    /// This isolates whether the problem is recording vs. transcription.
    private func transcribeAuditionFile() async {
        guard let url = savedWavURL else { return }
        auditionStatus = "Transcribing audition file..."
        transcribeResult = ""

        do {
            // Make sure model is prepared
            if voiceService.modelStatus != .ready {
                try await voiceService.prepareModel()
            }

            // Create a fresh WhisperKit instance and fully load it
            let kit = try await WhisperKit(model: "base")
            try await kit.loadModels()
            try await kit.loadTokenizerIfNeeded()

            let modelState = kit.modelState
            let hasTokenizer = kit.tokenizer != nil
            auditionStatus = "Model: \(modelState), tokenizer: \(hasTokenizer)"

            let options = DecodingOptions(
                language: "en",
                temperature: 0.0,
                temperatureFallbackCount: 3
            )

            // Try file-based transcription
            let fileResults = try await kit.transcribe(audioPath: url.path, decodeOptions: options)
            let fileText = fileResults.map(\.text).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)

            // Also try array-based transcription using WhisperKit's own resampler
            let audioFile = try AVAudioFile(forReading: url)
            if let resampledBuffer = AudioProcessor.resampleAudio(
                fromFile: audioFile,
                toSampleRate: 16000,
                channelCount: 1
            ), let floatData = resampledBuffer.floatChannelData?[0] {
                var samples = Array(UnsafeBufferPointer(start: floatData, count: Int(resampledBuffer.frameLength)))

                // Normalize to 0.9 peak
                let peak = samples.map { abs($0) }.max() ?? 0
                if peak > 0.001 {
                    let gain: Float = 0.9 / peak
                    if gain > 1.0 {
                        samples = samples.map { $0 * gain }
                    }
                }

                print("[TEST] Resampled: \(samples.count) samples, peak=\(samples.map { abs($0) }.max() ?? 0)")

                let arrayResults = try await kit.transcribe(audioArray: samples, decodeOptions: options)
                let arrayText = arrayResults.map(\.text).joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                transcribeResult = "File: \(fileText)\nArray(normalized): \(arrayText)"

                print("[TEST] Array-based: '\(arrayText)'")
                for (i, r) in arrayResults.enumerated() {
                    for (j, s) in r.segments.enumerated() {
                        print("[TEST] array seg[\(i)][\(j)]: avgLogProb=\(s.avgLogprob) noSpeech=\(s.noSpeechProb) text='\(s.text)'")
                    }
                }
            } else {
                transcribeResult = "File: \(fileText)\nArray: resample failed"
            }

            auditionStatus = "Transcription done — see results below"

            print("[TEST] File-based: '\(fileText)'")
            for (i, r) in fileResults.enumerated() {
                for (j, s) in r.segments.enumerated() {
                    print("[TEST] file seg[\(i)][\(j)]: avgLogProb=\(s.avgLogprob) noSpeech=\(s.noSpeechProb) text='\(s.text)'")
                }
            }
        } catch {
            transcribeResult = "Error: \(error.localizedDescription)"
            auditionStatus = "Transcription failed"
            print("[TEST] Error: \(error)")
        }
    }

    private func playAudition() {
        guard let url = savedWavURL else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            auditionStatus = "Playing..."
        } catch {
            auditionStatus = "Playback error: \(error.localizedDescription)"
        }
    }

}

#Preview {
    NavigationStack {
        VoiceTestView()
    }
}
