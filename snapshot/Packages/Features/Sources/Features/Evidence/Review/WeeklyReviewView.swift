import SwiftUI
import Domain
import DesignSystem

/// Weekly review screen showing insight cards.
public struct WeeklyReviewView: View {
    @Bindable var viewModel: WeeklyReviewViewModel
    var onReviseProtocol: (() -> Void)?

    public init(viewModel: WeeklyReviewViewModel, onReviseProtocol: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onReviseProtocol = onReviseProtocol
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                if viewModel.isLoading {
                    ProgressView("Generating insights...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if viewModel.insights.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.insights) { insight in
                        insightCardView(insight)
                    }

                    if viewModel.insights.contains(where: { $0.type == .revisionSuggestion }) {
                        Button {
                            onReviseProtocol?()
                        } label: {
                            Label("Revise Protocol", systemImage: "pencil.and.outline")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Weekly Review")
        .task {
            await viewModel.loadReview()
        }
    }

    // MARK: - Insight Card

    private func insightCardView(_ insight: InsightCard) -> some View {
        HStack(alignment: .top, spacing: CBTSpacing.sm) {
            Image(systemName: iconForType(insight.type))
                .font(.title2)
                .foregroundStyle(colorForType(insight.type))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                Text(insight.title)
                    .font(CBTTypography.body)
                    .fontWeight(.medium)
                Text(insight.body)
                    .font(CBTTypography.detail)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(CBTSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: CBTSpacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Not enough data yet")
                .font(CBTTypography.body)
            Text("Complete more runs to generate insights.")
                .font(CBTTypography.detail)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Helpers

    private func iconForType(_ type: InsightType) -> String {
        switch type {
        case .emotionTrend: "chart.line.uptrend.xyaxis"
        case .beliefShift: "arrow.down.right"
        case .experimentOutcome: "flask"
        case .measureChange: "waveform.path.ecg"
        case .consistencyStreak: "flame"
        case .revisionSuggestion: "exclamationmark.triangle"
        case .completionCandidate: "checkmark.seal"
        }
    }

    private func colorForType(_ type: InsightType) -> Color {
        switch type {
        case .emotionTrend, .beliefShift: .blue
        case .experimentOutcome, .consistencyStreak: .green
        case .measureChange: .purple
        case .revisionSuggestion: .orange
        case .completionCandidate: .green
        }
    }
}
