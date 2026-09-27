import Foundation
import Domain

/// Evaluates PHQ-9 scores for chronic non-response or suicidality.
enum EscalationEvaluator {

    /// PHQ-9 increase threshold to flag chronic non-response.
    static let increaseThreshold: Int = 5

    /// Evaluate PHQ-9 measure scores for escalation.
    ///
    /// Two checks:
    /// 1. Item 9 (suicidality) ≥ 1 → acute risk alert (overrides trend check)
    /// 2. Total score increase ≥ 5 over last 2 administrations → chronic non-response
    static func evaluate(scores: [MeasureScore]) -> SafetyAlert? {
        // Only consider PHQ-9 scores (sorted by date, ascending)
        let sorted = scores.sorted { $0.date < $1.date }

        // Check 1: PHQ-9 item 9 (suicidality) on most recent score
        if let latest = sorted.last,
           let items = latest.itemResponses,
           items.count >= 9,
           items[8] >= 1 {
            return SafetyAlert(
                kind: .acuteRisk,
                message: "Your recent responses suggest you may be having thoughts of self-harm. Please reach out to one of the support services below.",
                canContinue: false
            )
        }

        // Check 2: Score increase ≥ 5 over last 2 administrations
        guard sorted.count >= 2 else { return nil }

        let previous = sorted[sorted.count - 2]
        let current = sorted[sorted.count - 1]
        let increase = current.totalScore - previous.totalScore

        guard increase >= increaseThreshold else { return nil }

        return SafetyAlert(
            kind: .chronicNonResponse,
            message: "You've been working hard. Your scores have increased recently — sometimes talking with a professional helps too.",
            canContinue: true
        )
    }
}
