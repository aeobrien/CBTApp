import Foundation

/// Result of evaluating whether a protocol is ready for completion.
public struct CompletionCandidate: Sendable, Equatable {
    public var isCandidate: Bool
    public var reason: String
    public var suggestedKeyTrigger: String?
    public var suggestedUpdatedBelief: String?
    public var suggestedBestInterventionID: String?
    public var suggestedBestInterventionTitle: String?

    public init(
        isCandidate: Bool,
        reason: String,
        suggestedKeyTrigger: String? = nil,
        suggestedUpdatedBelief: String? = nil,
        suggestedBestInterventionID: String? = nil,
        suggestedBestInterventionTitle: String? = nil
    ) {
        self.isCandidate = isCandidate
        self.reason = reason
        self.suggestedKeyTrigger = suggestedKeyTrigger
        self.suggestedUpdatedBelief = suggestedUpdatedBelief
        self.suggestedBestInterventionID = suggestedBestInterventionID
        self.suggestedBestInterventionTitle = suggestedBestInterventionTitle
    }
}

/// Evaluates whether a protocol has achieved sustained improvement and is ready for completion.
public enum CompletionDetector {

    /// Check if a protocol is ready for completion based on run history.
    ///
    /// Completion criteria (all must be met):
    /// - At least 5 completed runs
    /// - Average emotion change over last 5 runs is negative (improving)
    /// - Belief strength after in last 3 runs is <= 30
    /// - No `gotWorse` tags in last 3 runs
    public static func evaluate(cbtProtocol: CBTProtocol, runs: [Run]) -> CompletionCandidate {
        let completed = runs
            .filter { $0.completionStatus == .completed }
            .sorted { $0.timestampStart < $1.timestampStart }

        // Criterion 1: at least 5 completed runs
        guard completed.count >= 5 else {
            return CompletionCandidate(
                isCandidate: false,
                reason: "Need at least 5 completed runs (\(completed.count) so far)."
            )
        }

        let lastFive = Array(completed.suffix(5))
        let lastThree = Array(completed.suffix(3))

        // Criterion 2: average emotion change over last 5 runs is negative
        let emotionChanges = lastFive.compactMap(\.emotionChange)
        guard !emotionChanges.isEmpty else {
            return CompletionCandidate(
                isCandidate: false,
                reason: "Not enough emotion data to evaluate improvement."
            )
        }
        let avgChange = emotionChanges.reduce(0, +) / Double(emotionChanges.count)
        guard avgChange < 0 else {
            return CompletionCandidate(
                isCandidate: false,
                reason: "Emotion change is not consistently improving (avg: \(String(format: "%+.1f", avgChange)))."
            )
        }

        // Criterion 3: belief strength after in last 3 runs is <= 30
        let recentBeliefs = lastThree.compactMap(\.beliefStrengthAfter)
        guard !recentBeliefs.isEmpty else {
            return CompletionCandidate(
                isCandidate: false,
                reason: "Not enough belief strength data to evaluate."
            )
        }
        let allBeliefsLow = recentBeliefs.allSatisfy { $0 <= 30 }
        guard allBeliefsLow else {
            return CompletionCandidate(
                isCandidate: false,
                reason: "Belief strength is still above 30 in recent runs."
            )
        }

        // Criterion 4: no gotWorse tags in last 3 runs
        let hasGotWorse = lastThree.flatMap(\.outcomeTags).contains(.gotWorse)
        guard !hasGotWorse else {
            return CompletionCandidate(
                isCandidate: false,
                reason: "Recent runs include 'got worse' outcomes."
            )
        }

        // All criteria met — build suggestions
        let trigger = cbtProtocol.whenToUse.first ?? cbtProtocol.targets.targetBelief
        let updatedBelief = cbtProtocol.targets.targetBelief

        // Find most-used intervention
        var interventionCounts: [String: Int] = [:]
        for run in completed {
            for id in run.chosenInterventions {
                interventionCounts[id, default: 0] += 1
            }
        }
        let bestID = interventionCounts.max(by: { $0.value < $1.value })?.key
        let bestTitle = cbtProtocol.interventions.first(where: { $0.interventionID == bestID })?.title
            ?? cbtProtocol.interventions.first(where: { $0.title == bestID })?.title
            ?? bestID

        return CompletionCandidate(
            isCandidate: true,
            reason: "Sustained improvement across \(completed.count) runs with low belief strength and consistent positive outcomes.",
            suggestedKeyTrigger: trigger,
            suggestedUpdatedBelief: updatedBelief,
            suggestedBestInterventionID: bestID,
            suggestedBestInterventionTitle: bestTitle
        )
    }
}
