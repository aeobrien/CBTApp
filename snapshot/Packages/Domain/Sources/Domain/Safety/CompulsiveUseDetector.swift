import Foundation

/// Detects compulsive use patterns: excessive frequency or non-improvement loops.
public enum CompulsiveUseDetector {

    /// Maximum completed runs in a 24-hour window before flagging.
    static let frequencyThreshold: Int = 6

    /// Number of consecutive non-improving runs before flagging.
    static let nonImprovementThreshold: Int = 8

    /// Evaluate runs for compulsive use patterns.
    public static func evaluate(runs: [Run]) -> SafetyAlert? {
        let completed = runs
            .filter { $0.completionStatus == .completed }
            .sorted { $0.timestampStart < $1.timestampStart }

        // Check 1: Excessive frequency — 6+ completed runs in the last 24 hours
        if let frequencyAlert = checkFrequency(completed) {
            return frequencyAlert
        }

        // Check 2: Non-improvement loop — 8+ consecutive runs with no improvement
        if let loopAlert = checkNonImprovementLoop(completed) {
            return loopAlert
        }

        return nil
    }

    private static func checkFrequency(_ completed: [Run]) -> SafetyAlert? {
        guard completed.count >= frequencyThreshold else { return nil }

        let now = completed.last?.timestampStart ?? Date()
        let twentyFourHoursAgo = now.addingTimeInterval(-86400)
        let recentCount = completed.filter { $0.timestampStart >= twentyFourHoursAgo }.count

        guard recentCount >= frequencyThreshold else { return nil }

        return SafetyAlert(
            kind: .compulsiveUse,
            message: "You've completed \(recentCount) runs in the last 24 hours. Taking breaks between runs can help you process what you've learned.",
            canContinue: true
        )
    }

    private static func checkNonImprovementLoop(_ completed: [Run]) -> SafetyAlert? {
        guard completed.count >= nonImprovementThreshold else { return nil }

        let recent = completed.suffix(nonImprovementThreshold)
        let allNonImproving = recent.allSatisfy { run in
            guard let change = run.emotionChange else { return false }
            return change >= 0 // no improvement (stayed same or worsened)
        }

        guard allNonImproving else { return nil }

        return SafetyAlert(
            kind: .compulsiveUse,
            message: "Your last \(nonImprovementThreshold) runs haven't shown improvement. It might help to try a different approach or talk with a professional.",
            canContinue: true
        )
    }
}
