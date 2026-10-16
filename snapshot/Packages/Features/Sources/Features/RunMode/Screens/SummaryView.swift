import SwiftUI
import Domain
import DesignSystem

/// Screen F: Summary and helpfulness rating.
struct SummaryView: View {
    @Bindable var viewModel: RunFlowViewModel
    var onFinish: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                // Summary text
                Text(viewModel.summaryText)
                    .font(CBTTypography.body)
                    .padding(CBTSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                    )

                // Helpfulness rating
                VStack(spacing: CBTSpacing.sm) {
                    Text("Was this run helpful?")
                        .font(CBTTypography.bodySecondary)

                    HStack(spacing: CBTSpacing.xl) {
                        Button {
                            viewModel.helpfulnessRating = .helpful
                        } label: {
                            VStack(spacing: CBTSpacing.xs) {
                                Image(systemName: viewModel.helpfulnessRating == .helpful
                                      ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .font(.title)
                                    .foregroundStyle(viewModel.helpfulnessRating == .helpful
                                                     ? CBTColors.positive : .secondary)
                                Text("Helpful")
                                    .font(CBTTypography.detail)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            viewModel.helpfulnessRating = .notHelpful
                        } label: {
                            VStack(spacing: CBTSpacing.xs) {
                                Image(systemName: viewModel.helpfulnessRating == .notHelpful
                                      ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .font(.title)
                                    .foregroundStyle(viewModel.helpfulnessRating == .notHelpful
                                                     ? CBTColors.negative : .secondary)
                                Text("Not helpful")
                                    .font(CBTTypography.detail)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)

                // Finish button
                Button("Done") {
                    Task {
                        await viewModel.finishRun()
                        onFinish()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Summary")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        SummaryView(viewModel: .preview()) { }
    }
}
