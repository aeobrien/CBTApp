import Foundation

/// Testable protocol for safety detection, consumed by ViewModels.
public protocol SafetySystemProtocol: AnyObject, Sendable {
    /// Scan free-text input for acute risk language.
    func scanText(_ text: String) -> SafetyAlert?

    /// Evaluate PHQ-9 trend and item 9 for chronic non-response or suicidality.
    func evaluateChronicNonResponse(scores: [MeasureScore]) -> SafetyAlert?

    /// Check whether the user has been away for 14+ days.
    func evaluateDisengagement(runs: [Run], relativeTo now: Date) -> SafetyAlert?

    /// Check for excessive run frequency or non-improvement loops.
    func evaluateCompulsiveUse(runs: [Run]) -> SafetyAlert?
}
