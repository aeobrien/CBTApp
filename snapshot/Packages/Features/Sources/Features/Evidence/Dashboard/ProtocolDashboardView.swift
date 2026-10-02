import SwiftUI
import Charts
import Domain
import DesignSystem

/// Dashboard showing protocol stats, charts, and measure scores.
public struct ProtocolDashboardView: View {
    @Bindable var viewModel: ProtocolDashboardViewModel
    var onWeeklyReview: () -> Void
    var onAdministerMeasure: (MeasureDefinition) -> Void
    var onComplete: (CompletionCandidate) -> Void

    public init(
        viewModel: ProtocolDashboardViewModel,
        onWeeklyReview: @escaping () -> Void,
        onAdministerMeasure: @escaping (MeasureDefinition) -> Void,
        onComplete: @escaping (CompletionCandidate) -> Void
    ) {
        self.viewModel = viewModel
        self.onWeeklyReview = onWeeklyReview
        self.onAdministerMeasure = onAdministerMeasure
        self.onComplete = onComplete
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                if viewModel.isLoading {
                    ProgressView("Loading dashboard...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let stats = viewModel.stats {
                    statsSummarySection(stats)
                    beliefChartSection(stats)
                    outcomeSection(stats)
                    measuresSection
                    controlsSection
                }
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Dashboard")
        .task {
            await viewModel.loadDashboard()
        }
    }

    // MARK: - Stats Summary

    @ViewBuilder
    private func statsSummarySection(_ stats: DashboardStats) -> some View {
        VStack(alignment: .leading, spacing: CBTSpacing.sm) {
            Text("Overview")
                .font(CBTTypography.sectionTitle)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CBTSpacing.sm) {
                statCard(label: "Runs", value: "\(stats.completedRunCount)")
                statCard(label: "Avg emotion change", value: stats.averageEmotionChange.map { String(format: "%+.1f%%", $0) } ?? "—")
                statCard(label: "Helpful", value: stats.helpfulnessRate.map { String(format: "%.0f%%", $0 * 100) } ?? "—")
                statCard(label: "Avg duration", value: stats.averageDurationSeconds.map { formatDuration($0) } ?? "—")
            }
        }
    }

    private func statCard(label: String, value: String) -> some View {
        VStack(spacing: CBTSpacing.xs) {
            Text(value)
                .font(CBTTypography.sectionTitle)
            Text(label)
                .font(CBTTypography.detail)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(CBTSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
    }

    // MARK: - Belief Strength Chart

    @ViewBuilder
    private func beliefChartSection(_ stats: DashboardStats) -> some View {
        if !stats.beliefStrengthTrend.isEmpty {
            VStack(alignment: .leading, spacing: CBTSpacing.sm) {
                Text("Belief Strength")
                    .font(CBTTypography.sectionTitle)

                Chart {
                    ForEach(Array(stats.beliefStrengthTrend.enumerated()), id: \.offset) { _, point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Before", point.before)
                        )
                        .foregroundStyle(by: .value("Type", "Before"))

                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("After", point.after)
                        )
                        .foregroundStyle(by: .value("Type", "After"))
                    }
                }
                .chartYScale(domain: 0...100)
                .chartForegroundStyleScale([
                    "Before": Color.orange,
                    "After": Color.blue
                ])
                .frame(height: 200)
            }
        }
    }

    // MARK: - Outcome Breakdown

    @ViewBuilder
    private func outcomeSection(_ stats: DashboardStats) -> some View {
        if !stats.outcomeTagCounts.isEmpty {
            VStack(alignment: .leading, spacing: CBTSpacing.sm) {
                Text("Outcomes")
                    .font(CBTTypography.sectionTitle)

                let chartData = stats.outcomeTagCounts
                    .sorted { $0.value > $1.value }
                    .map { OutcomeChartEntry(tag: $0.key, count: $0.value) }

                Chart(chartData) { entry in
                    BarMark(
                        x: .value("Count", entry.count),
                        y: .value("Tag", entry.tag.displayName)
                    )
                    .foregroundStyle(colorForTag(entry.tag))
                    .annotation(position: .trailing) {
                        Text("\(entry.count)")
                            .font(CBTTypography.detail)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartXAxis(.hidden)
                .frame(height: CGFloat(max(chartData.count, 1) * 44))
            }
        }
    }

    // MARK: - Standardised Measures

    @ViewBuilder
    private var measuresSection: some View {
        if !viewModel.measureScores.isEmpty {
            VStack(alignment: .leading, spacing: CBTSpacing.sm) {
                Text("Standardised Measures")
                    .font(CBTTypography.sectionTitle)

                ForEach(Array(viewModel.measureScores.keys.sorted()), id: \.self) { measureID in
                    if let def = MeasureDefinition.from(measureID: measureID) {
                        let scores = viewModel.measureScores[measureID] ?? []
                        let latest = scores.max(by: { $0.date < $1.date })
                        let band = latest.flatMap { def.band(for: $0.totalScore) }

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(def.fullName)
                                    .font(CBTTypography.body)
                                if let latest, let band {
                                    Text("Score: \(latest.totalScore) — \(band.label)")
                                        .font(CBTTypography.detail)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Not yet administered")
                                        .font(CBTTypography.detail)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Button("Administer") {
                                onAdministerMeasure(def)
                            }
                            .font(CBTTypography.detail)
                            .buttonStyle(.bordered)
                        }
                        .padding(CBTSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(spacing: CBTSpacing.sm) {
            Button {
                onWeeklyReview()
            } label: {
                Label("Weekly Review", systemImage: "chart.bar.doc.horizontal")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if let candidate = viewModel.completionCandidate, candidate.isCandidate {
                Button {
                    onComplete(candidate)
                } label: {
                    Label("Complete Protocol", systemImage: "checkmark.seal")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(minutes)m \(secs)s"
    }

    private func colorForTag(_ tag: OutcomeTag) -> Color {
        switch tag {
        case .intensityDropped, .predictionDidntHappen, .canHandleMoreThanThought:
            .green
        case .sameButTolerable, .uncomfortableButTolerable:
            .blue
        case .gotWorse, .ruminatedAnyway, .avoided:
            .red
        }
    }
}

/// Chart data entry for outcome tag counts.
private struct OutcomeChartEntry: Identifiable {
    let id = UUID()
    let tag: OutcomeTag
    let count: Int
}
