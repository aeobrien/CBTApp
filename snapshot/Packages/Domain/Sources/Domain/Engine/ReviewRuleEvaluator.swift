import Foundation

/// Result of evaluating a review rule.
public struct ReviewRuleResult: Sendable, Equatable {
    public var rule: ReviewRule
    public var triggered: Bool
    public var reason: String

    public init(rule: ReviewRule, triggered: Bool, reason: String) {
        self.rule = rule
        self.triggered = triggered
        self.reason = reason
    }
}

/// Evaluates review rules against run history.
///
/// Built-in rule conditions:
/// - `"runs >= N"` — trigger after N completed runs
/// - `"no_shift_after_N"` — trigger if no improvement after N runs
///
/// The condition strings are parsed from the protocol's review rules.
public enum ReviewRuleEvaluator {

    /// Evaluate all review rules.
    public static func evaluate(
        rules: [ReviewRule],
        completedRunCount: Int,
        recentEmotionChanges: [Double]
    ) -> [ReviewRuleResult] {
        rules.map { rule in
            evaluateRule(
                rule,
                completedRunCount: completedRunCount,
                recentEmotionChanges: recentEmotionChanges
            )
        }
    }

    private static func evaluateRule(
        _ rule: ReviewRule,
        completedRunCount: Int,
        recentEmotionChanges: [Double]
    ) -> ReviewRuleResult {
        let condition = rule.condition.lowercased().trimmingCharacters(in: .whitespaces)

        // Pattern: "runs >= N"
        if let threshold = parseRunsThreshold(condition) {
            let triggered = completedRunCount >= threshold
            return ReviewRuleResult(
                rule: rule,
                triggered: triggered,
                reason: triggered
                    ? "Completed \(completedRunCount) runs (threshold: \(threshold))"
                    : "Only \(completedRunCount)/\(threshold) runs completed"
            )
        }

        // Pattern: "no_shift_after_N"
        if let threshold = parseNoShiftThreshold(condition) {
            let triggered = evaluateNoShift(
                recentEmotionChanges: recentEmotionChanges,
                threshold: threshold
            )
            return ReviewRuleResult(
                rule: rule,
                triggered: triggered,
                reason: triggered
                    ? "No meaningful shift detected after \(threshold) runs"
                    : "Shifts detected or insufficient data"
            )
        }

        // Unknown condition — don't trigger
        return ReviewRuleResult(
            rule: rule,
            triggered: false,
            reason: "Unknown condition format: '\(rule.condition)'"
        )
    }

    // MARK: - Condition Parsers

    /// Parse run count threshold from various formats:
    /// - `"runs >= 5"`
    /// - `"after_5_runs"`
    static func parseRunsThreshold(_ condition: String) -> Int? {
        // Try "runs >= N"
        let gePattern = #"runs\s*>=\s*(\d+)"#
        if let value = firstCaptureInt(pattern: gePattern, in: condition) {
            return value
        }
        // Try "after_N_runs"
        let afterPattern = #"after_(\d+)_runs"#
        return firstCaptureInt(pattern: afterPattern, in: condition)
    }

    /// Parse no-shift threshold from various formats:
    /// - `"no_shift_after_3"`
    /// - `"no_shift_after_3_runs"`
    static func parseNoShiftThreshold(_ condition: String) -> Int? {
        let pattern = #"no_shift_after_(\d+)"#
        return firstCaptureInt(pattern: pattern, in: condition)
    }

    private static func firstCaptureInt(pattern: String, in string: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
              let range = Range(match.range(at: 1), in: string) else {
            return nil
        }
        return Int(string[range])
    }

    /// Check if recent emotion changes show no meaningful improvement.
    /// A "shift" is defined as an average emotion change of at least -5
    /// (negative = improvement).
    private static func evaluateNoShift(
        recentEmotionChanges: [Double],
        threshold: Int
    ) -> Bool {
        guard recentEmotionChanges.count >= threshold else { return false }
        let recent = recentEmotionChanges.suffix(threshold)
        let average = recent.reduce(0, +) / Double(recent.count)
        // No shift if average change is >= -5 (not enough improvement)
        return average >= -5
    }
}
