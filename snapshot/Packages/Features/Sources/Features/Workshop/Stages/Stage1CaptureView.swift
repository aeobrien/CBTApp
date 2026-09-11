import SwiftUI
import Domain
import DesignSystem

/// Stage 1: Capture the situation, hot thought, emotion, and urge.
///
/// This is the starting point of the workshop — the user describes
/// a specific instance of the pattern they want to work on.
struct Stage1CaptureView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Situation
                VStack(alignment: .leading, spacing: 8) {
                    Text("What was the situation?")
                        .font(.headline)
                    Text("Describe a recent time this pattern showed up.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("e.g. I was about to present at the team meeting...", text: $viewModel.situation, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                        .voiceInput(text: $viewModel.situation, voiceService: viewModel.voiceInputService)
                }

                // Hot thought
                VStack(alignment: .leading, spacing: 8) {
                    Text("What went through your mind?")
                        .font(.headline)
                    Text("The thought that felt most distressing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("e.g. I'm going to mess this up", text: $viewModel.hotThought, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                        .voiceInput(text: $viewModel.hotThought, voiceService: viewModel.voiceInputService)
                }

                // Emotion
                VStack(alignment: .leading, spacing: 8) {
                    Text("What emotion did you feel?")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                        ForEach(EmotionType.allCases) { emotion in
                            SelectableChip(
                                label: emotion.displayName,
                                isSelected: viewModel.selectedEmotion == emotion
                            ) {
                                viewModel.selectedEmotion = emotion
                            }
                        }
                    }
                }

                // Intensity
                if viewModel.selectedEmotion != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How intense was it?")
                            .font(.headline)
                        CBTSlider(label: "Intensity", value: Binding(
                            get: { Double(viewModel.emotionIntensity) },
                            set: { viewModel.emotionIntensity = Int($0) }
                        ))
                    }
                }

                // Urge
                VStack(alignment: .leading, spacing: 8) {
                    Text("What did you feel the urge to do?")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(UrgeType.allCases) { urge in
                            SelectableChip(
                                label: urge.displayName,
                                isSelected: viewModel.selectedUrge == urge
                            ) {
                                viewModel.selectedUrge = urge
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Capture")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .disabled(viewModel.situation.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Stage1CaptureView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
