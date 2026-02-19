import SwiftUI
import Domain
import DesignSystem

/// Screen C: Guided discovery — explore the hot thought with predictions and alternatives.
struct GuidedDiscoveryView: View {
    @Bindable var viewModel: RunFlowViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                // Display the hot thought
                if !viewModel.displayedHotThought.isEmpty {
                    VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                        Text("Your hot thought")
                            .font(CBTTypography.bodySecondary)
                            .foregroundStyle(.secondary)
                        Text("\"\(viewModel.displayedHotThought)\"")
                            .font(CBTTypography.body)
                            .italic()
                    }
                    .padding(CBTSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                            .fill(CBTColors.accent.opacity(0.05))
                    )
                }

                // Prediction
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("What do you predict will happen?")
                        .font(CBTTypography.bodySecondary)
                    TextField("If this thought is true, then...", text: $viewModel.predictionResponse, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }

                // Alternative
                VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                    Text("Is there another way to see this?")
                        .font(CBTTypography.bodySecondary)
                    TextField("An alternative perspective might be...", text: $viewModel.alternativeResponse, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Guided Discovery")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Skip") {
                    Task { await viewModel.skipDiscovery() }
                }
                .font(CBTTypography.bodySecondary)
            }
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
        GuidedDiscoveryView(viewModel: .preview())
    }
}
