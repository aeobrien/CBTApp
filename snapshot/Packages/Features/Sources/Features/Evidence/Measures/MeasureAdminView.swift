import SwiftUI
import Domain
import DesignSystem

/// Questionnaire flow for administering a standardised measure.
public struct MeasureAdminView: View {
    @Bindable var viewModel: MeasureAdminViewModel
    var onDismiss: () -> Void

    public init(viewModel: MeasureAdminViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.isComplete {
                resultView
            } else {
                questionView
            }
        }
        .navigationTitle(viewModel.definition.fullName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await viewModel.loadPreviousScore()
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: CBTSpacing.lg) {
            // Progress bar
            ProgressView(value: Double(viewModel.currentItemIndex), total: Double(viewModel.definition.items.count))
                .padding(.horizontal, CBTSpacing.md)

            Text("Over the last 2 weeks, how often have you been bothered by:")
                .font(CBTTypography.detail)
                .foregroundStyle(.secondary)
                .padding(.horizontal, CBTSpacing.md)

            Spacer()

            // Question text
            Text(viewModel.definition.items[viewModel.currentItemIndex])
                .font(CBTTypography.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CBTSpacing.lg)

            Spacer()

            // Response options
            VStack(spacing: CBTSpacing.sm) {
                ForEach(0..<viewModel.definition.responseOptions.count, id: \.self) { index in
                    let option = viewModel.definition.responseOptions[index]
                    let isSelected = viewModel.currentItemIndex < viewModel.responses.count && viewModel.responses[viewModel.currentItemIndex] == index
                    Button {
                        viewModel.selectResponse(index)
                        viewModel.advance()
                    } label: {
                        HStack {
                            Text("\(index)")
                                .font(CBTTypography.detail)
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text(option)
                                .font(CBTTypography.body)
                            Spacer()
                        }
                        .padding(CBTSpacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CBTSpacing.md)

            // Back button
            if viewModel.currentItemIndex > 0 {
                Button("Back") {
                    viewModel.goBack()
                }
                .font(CBTTypography.bodySecondary)
            }

            Spacer()
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: CBTSpacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Score: \(viewModel.totalScore)")
                .font(CBTTypography.sectionTitle)

            if let band = viewModel.scoringBand {
                Text(band.label)
                    .font(CBTTypography.body)
                    .foregroundStyle(colorForSeverity(band.severity))
            }

            if let previous = viewModel.previousScore {
                let change = viewModel.totalScore - previous.totalScore
                HStack(spacing: CBTSpacing.xs) {
                    Text("Previous: \(previous.totalScore)")
                    Text("(\(change > 0 ? "+" : "")\(change))")
                        .foregroundStyle(change < 0 ? .green : change > 0 ? .red : .secondary)
                }
                .font(CBTTypography.detail)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Save & Close") {
                Task {
                    await viewModel.submit()
                    onDismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, CBTSpacing.md)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func colorForSeverity(_ severity: Severity) -> Color {
        switch severity {
        case .minimal: .green
        case .mild: .blue
        case .moderate: .orange
        case .moderatelySevere: .red.opacity(0.8)
        case .severe: .red
        }
    }
}
