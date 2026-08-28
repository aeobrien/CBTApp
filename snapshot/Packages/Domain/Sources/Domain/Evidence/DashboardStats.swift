import Foundation

/// Aggregated statistics for a protocol's run history.
public struct DashboardStats: Sendable, Equatable {
    public var completedRunCount: Int
    public var averageEmotionChange: Double?
    public var beliefStrengthTrend: [(date: Date, before: Int, after: Int)]
    public var outcomeTagCounts: [OutcomeTag: Int]
    public var helpfulnessRate: Double?
    public var mostUsedInterventionID: String?
    public var averageDurationSeconds: Double?

    public init(
        completedRunCount: Int = 0,
        averageEmotionChange: Double? = nil,
        beliefStrengthTrend: [(date: Date, before: Int, after: Int)] = [],
        outcomeTagCounts: [OutcomeTag: Int] = [:],
        helpfulnessRate: Double? = nil,
        mostUsedInterventionID: String? = nil,
        averageDurationSeconds: Double? = nil
    ) {
        self.completedRunCount = completedRunCount
        self.averageEmotionChange = averageEmotionChange
        self.beliefStrengthTrend = beliefStrengthTrend
        self.outcomeTagCounts = outcomeTagCounts
        self.helpfulnessRate = helpfulnessRate
        self.mostUsedInterventionID = mostUsedInterventionID
        self.averageDurationSeconds = averageDurationSeconds
    }

    // Equatable conformance — tuples aren't automatically Equatable
    public static func == (lhs: DashboardStats, rhs: DashboardStats) -> Bool {
        lhs.completedRunCount == rhs.completedRunCount &&
        lhs.averageEmotionChange == rhs.averageEmotionChange &&
        lhs.outcomeTagCounts == rhs.outcomeTagCounts &&
        lhs.helpfulnessRate == rhs.helpfulnessRate &&
        lhs.mostUsedInterventionID == rhs.mostUsedInterventionID &&
        lhs.averageDurationSeconds == rhs.averageDurationSeconds &&
        lhs.beliefStrengthTrend.count == rhs.beliefStrengthTrend.count
    }
}

/// Pure-function calculator that derives dashboard stats from an array of runs.
public enum DashboardStatsCalculator {

    public static func calculate(from runs: [Run]) -> DashboardStats {
        let completedRuns = runs.filter { $0.completionStatus == .completed }

        let completedCount = completedRuns.count

        // Average emotion change
        let emotionChanges = completedRuns.compactMap(\.emotionChange)
        let avgEmotionChange: Double? = emotionChanges.isEmpty
            ? nil
            : emotionChanges.reduce(0, +) / Double(emotionChanges.count)

        // Belief strength trend (chronological)
        let trend: [(date: Date, before: Int, after: Int)] = completedRuns
            .compactMap { run in
                guard let before = run.beliefStrengthBefore,
                      let after = run.beliefStrengthAfter else { return nil }
                return (date: run.timestampStart, before: before, after: after)
            }
            .sorted { $0.date < $1.date }

        // Outcome tag counts
        var tagCounts: [OutcomeTag: Int] = [:]
        for run in completedRuns {
            for tag in run.outcomeTags {
                tagCounts[tag, default: 0] += 1
            }
        }

        // Helpfulness rate
        let rated = completedRuns.compactMap(\.helpfulnessRating)
        let helpfulness: Double? = rated.isEmpty
            ? nil
            : Double(rated.filter { $0 == .helpful }.count) / Double(rated.count)

        // Most used intervention (mode)
        var interventionCounts: [String: Int] = [:]
        for run in completedRuns {
            for id in run.chosenInterventions {
                interventionCounts[id, default: 0] += 1
            }
        }
        let mostUsed = interventionCounts.max(by: { $0.value < $1.value })?.key

        // Average duration
        let durations = completedRuns.compactMap(\.durationSeconds)
        let avgDuration: Double? = durations.isEmpty
            ? nil
            : durations.reduce(0, +) / Double(durations.count)

        return DashboardStats(
            completedRunCount: completedCount,
            averageEmotionChange: avgEmotionChange,
            beliefStrengthTrend: trend,
            outcomeTagCounts: tagCounts,
            helpfulnessRate: helpfulness,
            mostUsedInterventionID: mostUsed,
            averageDurationSeconds: avgDuration
        )
    }
}
