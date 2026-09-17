import Foundation

/// Detects disengagement: no completed runs in 14+ days.
public enum DisengagementDetector {

    /// Threshold in days after which disengagement is flagged.
    static let thresholdDays: Int = 14

    /// Evaluate whether the user has disengaged from their protocol.
    ///
    /// - Returns nil if no completed runs exist (never engaged ≠ disengaged)
    /// - Returns nil if most recent completed run is within threshold
    /// - Returns a disengagement alert if the gap exceeds the threshold
    public static func evaluate(runs: [Run], relativeTo now: Date = Date()) -> SafetyAlert? {
        let completed = runs.filter { $0.completionStatus == .completed }
        guard let mostRecent = completed.max(by: { $0.timestampStart < $1.timestampStart }) else {
            return nil
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: mostRecent.timestampStart, to: now)
        let daysSince = components.day ?? 0

        guard daysSince >= thresholdDays else { return nil }

        return SafetyAlert(
            kind: .disengagement,
            message: "You haven't completed a run in \(daysSince) days. That's okay — pick up where you left off or archive this protocol.",
            canContinue: true
        )
    }
}
