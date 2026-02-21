import SwiftUI
import Domain
import Services
import Features
import DesignSystem
import Utilities

/// Test harness for Phase 11 voice input.
struct VoiceTestView: View {
    @State private var voiceService = WhisperVoiceInputService()
    @State private var testText = ""
    @State private var appendText = "Existing text here"
    @State private var statusMessage = "Ready"

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
}

#Preview {
    NavigationStack {
        VoiceTestView()
    }
}
