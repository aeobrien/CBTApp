import SwiftUI
import Domain
import DesignSystem

/// Screen E: Record the outcome — re-rate emotions, belief strength, pick outcome tags.
struct OutcomeView: View {
    @Bindable var viewModel: RunFlowViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                // Re-rate emotions
                VStack(alignment: .leading, spacing: CBTSpacing.sm) {
                    Text("How are your emotions now?")
                        .font(CBTTypography.bodySecondary)

                    ForEach($viewModel.emotionRatingsAfter) { $rating in
                        CBTSlider(
                            label: rating.emotion.displayName,
                            value: Binding(
                                get: { Double(rating.intensity) },
                                set: { rating.intensity = max(0, min(100, Int($0))) }
                            )
                        )
                    }

                    if viewModel.emotionRatingsAfter.isEmpty {
                        Text("No emotions to re-rate.")
                            .font(CBTTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Belief strength after
                BeliefStrengthSlider(
                    label: "How strongly do you believe the thought now?",
                    value: $viewModel.beliefStrengthAfter
                )

                // Outcome tags
                OutcomeTagSelector(selection: $viewModel.selectedOutcomeTags)

                // Learning note
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("What did you learn?")
                        .font(CBTTypography.bodySecondary)
                    TextField("Any insights from this run...", text: $viewModel.learningNote, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                        .voiceInput(text: $viewModel.learningNote, voiceService: viewModel.voiceInputService)
                }

                // Forward plan
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("Forward plan")
                        .font(CBTTypography.bodySecondary)
                    TextField("Next time I'll try...", text: $viewModel.forwardPlan, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                        .voiceInput(text: $viewModel.forwardPlan, voiceService: viewModel.voiceInputService)
                }
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Outcome")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OutcomeView(viewModel: .preview())
    }
}
