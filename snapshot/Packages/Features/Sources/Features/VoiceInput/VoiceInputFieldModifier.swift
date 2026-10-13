import SwiftUI
import Domain
import DesignSystem

/// View modifier that adds a microphone button and transcription editing to a text field.
///
/// Usage:
/// ```swift
/// TextField("Description...", text: $text)
///     .voiceInput(text: $text, voiceService: service)
/// ```
struct VoiceInputFieldModifier: ViewModifier {
    @Binding var text: String
    let voiceService: (any VoiceInputServiceProtocol)?
    @State private var viewModel: VoiceInputViewModel?

    func body(content: Content) -> some View {
        if let service = voiceService {
            HStack(alignment: .top, spacing: CBTSpacing.xs) {
                content

                let vm = viewModel ?? createViewModel(service: service)
                VoiceInputButton(isRecording: vm.isRecording) {
                    Task { await vm.toggleRecording() }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = VoiceInputViewModel(voiceService: service)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.isShowingTranscription ?? false },
                set: { newValue in
                    if !newValue { viewModel?.cancelTranscription() }
                }
            )) {
                if let vm = viewModel {
                    TranscriptionEditView(
                        text: Binding(
                            get: { vm.transcribedText },
                            set: { vm.transcribedText = $0 }
                        ),
                        onConfirm: {
                            let transcription = vm.confirmTranscription()
                            insertTranscription(transcription)
                        },
                        onCancel: {
                            vm.cancelTranscription()
                        }
                    )
                }
            }
            .alert("Microphone Access Required", isPresented: Binding(
                get: { viewModel?.isShowingPermissionDenied ?? false },
                set: { viewModel?.isShowingPermissionDenied = $0 }
            )) {
                #if os(iOS)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                #endif
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Voice input requires microphone access. Please enable it in Settings.")
            }
            .alert("Voice Input Error", isPresented: Binding(
                get: { viewModel?.errorMessage != nil },
                set: { if !$0 { viewModel?.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel?.errorMessage {
                    Text(error)
                }
            }
        } else {
            content
        }
    }

    private func createViewModel(service: any VoiceInputServiceProtocol) -> VoiceInputViewModel {
        let vm = VoiceInputViewModel(voiceService: service)
        viewModel = vm
        return vm
    }

    /// Insert transcription into the text field.
    /// If the field is non-empty, appends with a space and lowercases the first character.
    private func insertTranscription(_ transcription: String) {
        guard !transcription.isEmpty else { return }

        if text.isEmpty {
            text = transcription
        } else {
            // Lowercase first char when inserting mid-sentence
            var adjusted = transcription
            let first = adjusted.removeFirst()
            adjusted = String(first).lowercased() + adjusted
            text += " " + adjusted
        }
    }
}

extension View {
    /// Attach voice input capability to a text field.
    ///
    /// When `voiceService` is `nil`, the modifier has no effect (no mic button shown).
    public func voiceInput(text: Binding<String>, voiceService: (any VoiceInputServiceProtocol)?) -> some View {
        modifier(VoiceInputFieldModifier(text: text, voiceService: voiceService))
    }
}
