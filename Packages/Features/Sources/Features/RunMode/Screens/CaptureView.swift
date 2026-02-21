import SwiftUI
import Domain
import DesignSystem

/// Screen B: Capture the current situation, emotions, body signals, urge, and belief strength.
struct CaptureView: View {
    @Bindable var viewModel: RunFlowViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                // Situation
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("What's happening?")
                        .font(CBTTypography.bodySecondary)
                    TextField("Describe the situation...", text: $viewModel.situation, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...5)
                        .voiceInput(text: $viewModel.situation, voiceService: viewModel.voiceInputService)
                }

                // Hot thought
                hotThoughtSection(templates: viewModel.hotThoughtTemplates)

                // Emotions
                emotionSection

                // Body signals
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("Body signals")
                        .font(CBTTypography.bodySecondary)
                    ChipGrid(
                        items: BodySignal.allCases.map { $0 },
                        labelForItem: { $0.displayName },
                        selection: $viewModel.selectedBodySignals
                    )
                }

                // Urge
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("Urge")
                        .font(CBTTypography.bodySecondary)
                    FlowLayout(spacing: CBTSpacing.xs) {
                        ForEach(UrgeType.allCases) { urge in
                            SelectableChip(
                                label: urge.displayName,
                                isSelected: viewModel.selectedUrge == urge
                            ) {
                                viewModel.selectedUrge = viewModel.selectedUrge == urge ? nil : urge
                            }
                        }
                    }
                }

                // Belief strength
                BeliefStrengthSlider(value: $viewModel.beliefStrengthBefore)

                // Safety banner
                SafetyBanner(
                    message: "If you're in crisis, please reach out.",
                    resources: [
                        (name: "Samaritans", detail: "116 123"),
                        (name: "Crisis Text Line", detail: "Text SHOUT to 85258")
                    ]
                )
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Capture")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Skip") {
                    Task { await viewModel.skipCapture() }
                }
                .font(CBTTypography.bodySecondary)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.emotionRatings.isEmpty)
            }
        }
    }

    // MARK: - Hot thought section

    @ViewBuilder
    private func hotThoughtSection(templates: [String]) -> some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            Text("Hot thought")
                .font(CBTTypography.bodySecondary)

            if !templates.isEmpty {
                FlowLayout(spacing: CBTSpacing.xs) {
                    ForEach(templates, id: \.self) { thought in
                        SelectableChip(
                            label: thought,
                            isSelected: viewModel.selectedHotThought == thought
                        ) {
                            viewModel.selectedHotThought = viewModel.selectedHotThought == thought ? nil : thought
                        }
                    }
                }
            }

            TextField("Or type your own...", text: $viewModel.customHotThought)
                .textFieldStyle(.roundedBorder)
                .voiceInput(text: $viewModel.customHotThought, voiceService: viewModel.voiceInputService)
        }
    }

    // MARK: - Emotion section

    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.sm) {
            Text("Emotions")
                .font(CBTTypography.bodySecondary)

            // Chip grid for adding emotions
            FlowLayout(spacing: CBTSpacing.xs) {
                ForEach(EmotionType.allCases) { emotion in
                    let isSelected = viewModel.emotionRatings.contains { $0.emotion == emotion }
                    SelectableChip(label: emotion.displayName, isSelected: isSelected) {
                        if isSelected {
                            viewModel.emotionRatings.removeAll { $0.emotion == emotion }
                        } else {
                            viewModel.emotionRatings.append(EmotionRating(emotion: emotion, intensity: 50))
                        }
                    }
                }
            }

            // Sliders for selected emotions
            ForEach($viewModel.emotionRatings) { $rating in
                CBTSlider(
                    label: rating.emotion.displayName,
                    value: Binding(
                        get: { Double(rating.intensity) },
                        set: { rating.intensity = max(0, min(100, Int($0))) }
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView(viewModel: .preview())
    }
}
