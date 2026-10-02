import Foundation

/// The type of insight generated during weekly review.
public enum InsightType: String, Sendable {
    case emotionTrend
    case beliefShift
    case experimentOutcome
    case measureChange
    case consistencyStreak
    case revisionSuggestion
    case completionCandidate
}

/// A single insight card shown in the weekly review.
public struct InsightCard: Sendable, Equatable, Identifiable {
    public var id: UUID
    public var type: InsightType
    public var title: String
    public var body: String
    public var priority: Int

    public init(
        id: UUID = UUID(),
        type: InsightType,
        title: String,
        body: String,
        priority: Int
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.priority = priority
    }
}

/// Generates insight cards from recent runs and measure scores for weekly review.
public enum WeeklyReviewGenerator {

    /// Generate 3–5 insight cards from recent run data.
    /// - Parameters:
    ///   - runs: All runs for this protocol, sorted by date descending.
    ///   - cbtProtocol: The protocol being reviewed.
    ///   - measureScores: Scores keyed by measure ID.
    /// - Returns: Up to 5 insight cards sorted by priority (1 = highest).
    public static func generate(
        runs: [Run],
        cbtProtocol: CBTProtocol,
        measureScores: [String: [MeasureScore]] = [:]
    ) -> [InsightCard] {
        guard !runs.isEmpty else { return [] }

        var insights: [InsightCard] = []

        // Split runs into this week vs previous week
        let now = Date()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: now)!

        let thisWeek = runs.filter { $0.timestampStart >= sevenDaysAgo }
        let lastWeek = runs.filter { $0.timestampStart >= fourteenDaysAgo && $0.timestampStart < sevenDaysAgo }

        // 1. Emotion trend — compare avg emotion change this week vs last week
        if let thisAvg = averageEmotionChange(thisWeek), let lastAvg = averageEmotionChange(lastWeek) {
            let direction = thisAvg < lastAvg ? "improving" : "worsening"
            insights.append(InsightCard(
                type: .emotionTrend,
                title: "Emotion trend \(direction)",
                body: "Average emotion change this week: \(formatChange(thisAvg)) vs last week: \(formatChange(lastAvg)).",
                priority: 2
            ))
        }

        // 2. Belief shift — if belief strength after is consistently declining over 3+ runs
        let recentWithBelief = runs.prefix(5).compactMap { run -> Int? in
            run.beliefStrengthAfter
        }
        if recentWithBelief.count >= 3 {
            // Runs are sorted newest-first, so declining beliefs appear as ascending values
            let isDecreasing = zip(recentWithBelief, recentWithBelief.dropFirst()).allSatisfy { $0 <= $1 }
            if isDecreasing {
                insights.append(InsightCard(
                    type: .beliefShift,
                    title: "Belief strength declining",
                    body: "Your belief strength has been consistently decreasing over the last \(recentWithBelief.count) runs. This suggests the protocol is working.",
                    priority: 2
                ))
            }
        }

        // 3. Experiment outcome — summarise experiment-related tags
        let experimentTags: Set<OutcomeTag> = [.predictionDidntHappen, .canHandleMoreThanThought]
        let experimentTagCount = thisWeek.flatMap(\.outcomeTags).filter { experimentTags.contains($0) }.count
        if experimentTagCount > 0 {
            insights.append(InsightCard(
                type: .experimentOutcome,
                title: "Experiments are paying off",
                body: "You recorded \(experimentTagCount) positive experiment outcome\(experimentTagCount == 1 ? "" : "s") this week.",
                priority: 3
            ))
        }

        // 4. Measure change — if standardised measure score changed significantly
        for (measureID, scores) in measureScores {
            let sorted = scores.sorted { $0.date < $1.date }
            if sorted.count >= 2 {
                let latest = sorted[sorted.count - 1]
                let previous = sorted[sorted.count - 2]
                let change = latest.totalScore - previous.totalScore
                if abs(change) >= 3 {
                    let direction = change < 0 ? "improved" : "worsened"
                    insights.append(InsightCard(
                        type: .measureChange,
                        title: "\(measureID) score \(direction)",
                        body: "\(measureID) changed from \(previous.totalScore) to \(latest.totalScore) (\(change > 0 ? "+" : "")\(change)).",
                        priority: 1
                    ))
                }
            }
        }

        // 5. Consistency streak — 3+ runs this week
        if thisWeek.count >= 3 {
            insights.append(InsightCard(
                type: .consistencyStreak,
                title: "Consistency streak",
                body: "You completed \(thisWeek.count) runs this week. Regular practice strengthens new patterns.",
                priority: 4
            ))
        }

        // 6. Revision suggestion — majority of recent runs have gotWorse or ruminatedAnyway
        let recentOutcomes = Array(runs.prefix(5)).flatMap(\.outcomeTags)
        let negativeCount = recentOutcomes.filter { $0 == .gotWorse || $0 == .ruminatedAnyway }.count
        if negativeCount > recentOutcomes.count / 2 && !recentOutcomes.isEmpty {
            insights.append(InsightCard(
                type: .revisionSuggestion,
                title: "Consider revising this protocol",
                body: "Most of your recent runs show worsening or continued rumination. The protocol may need adjusting.",
                priority: 1
            ))
        }

        // 7. Completion candidate — delegates to CompletionDetector
        let candidate = CompletionDetector.evaluate(cbtProtocol: cbtProtocol, runs: runs)
        if candidate.isCandidate {
            insights.append(InsightCard(
                type: .completionCandidate,
                title: "Ready to complete?",
                body: candidate.reason,
                priority: 1
            ))
        }

        // Sort by priority and cap at 5
        return insights.sorted { $0.priority < $1.priority }.prefix(5).map { $0 }
    }

    // MARK: - Helpers

    private static func averageEmotionChange(_ runs: [Run]) -> Double? {
        let changes = runs.compactMap(\.emotionChange)
        guard !changes.isEmpty else { return nil }
        return changes.reduce(0, +) / Double(changes.count)
    }

    private static func formatChange(_ value: Double) -> String {
        String(format: "%+.1f", value)
    }
}
