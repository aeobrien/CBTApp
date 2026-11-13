import Foundation
import Domain

/// Risk level from acute risk classification.
public enum AcuteRiskLevel: Sendable, Equatable {
    case none
    case elevated
    case acute
}

/// Classifies free text for acute risk indicators using regex patterns.
///
/// Two tiers:
/// - **Acute** (canContinue: false): Direct crisis language with self-referential pronouns
/// - **Elevated** (canContinue: true): Passive ideation language
enum AcuteRiskClassifier {

    // Self-referential pronoun prefix to reduce false positives on metaphorical language.
    // Matches "I", "my", "myself" near the crisis phrase.
    private static let selfRef = #"(?:I|my|myself|I'm|I've|i|i'm|i've)\b"#

    /// Acute patterns — direct crisis language requiring self-reference nearby.
    private static let acutePatterns: [String] = [
        #"(?i)\b"# + selfRef + #".*?\b(?:kill\s+myself|end\s+my\s+life)\b"#,
        #"(?i)\b(?:kill\s+myself|end\s+my\s+life)\b"#,
        #"(?i)\b"# + selfRef + #".*?\b(?:want\s+to\s+die)\b"#,
        #"(?i)\b(?:want\s+to\s+die)\b"#,
        #"(?i)\b(?:suicidal)\b"#,
        #"(?i)\b"# + selfRef + #".*?\b(?:self[- ]?harm)\b"#,
        #"(?i)\b(?:can'?t\s+go\s+on)\b"#,
        #"(?i)\b(?:no\s+reason\s+to\s+live)\b"#,
    ]

    /// Elevated patterns — passive ideation, less immediate but still flagged.
    private static let elevatedPatterns: [String] = [
        #"(?i)\b(?:better\s+off\s+dead)\b"#,
        #"(?i)\b(?:thought\s+about\s+hurting\s+myself)\b"#,
        #"(?i)\b(?:no\s+hope)\b"#,
        #"(?i)\b(?:no\s+point)\b"#,
    ]

    /// Classify text for acute risk.
    static func classify(_ text: String) -> AcuteRiskLevel {
        guard !text.isEmpty else { return .none }

        // Filter out clearly metaphorical phrases before classification
        let cleaned = filterMetaphorical(text)

        for pattern in acutePatterns {
            if cleaned.range(of: pattern, options: .regularExpression) != nil {
                return .acute
            }
        }

        for pattern in elevatedPatterns {
            if cleaned.range(of: pattern, options: .regularExpression) != nil {
                return .elevated
            }
        }

        return .none
    }

    /// Build a SafetyAlert from a classification level, if applicable.
    static func alert(for level: AcuteRiskLevel) -> SafetyAlert? {
        switch level {
        case .none:
            return nil
        case .elevated:
            return SafetyAlert(
                kind: .acuteRisk,
                message: "It sounds like you're going through a really difficult time. Support is available if you need it.",
                canContinue: true
            )
        case .acute:
            return SafetyAlert(
                kind: .acuteRisk,
                message: "It sounds like you may be in crisis. Please reach out to one of the support services below — they're available right now and can help.",
                canContinue: false
            )
        }
    }

    /// Filter out common metaphorical phrases that would cause false positives.
    private static func filterMetaphorical(_ text: String) -> String {
        let metaphors = [
            #"(?i)\b(?:kill(?:ing|ed)?\s+(?:it|time|the\s+\w+))\b"#,
            #"(?i)\b(?:dying\s+(?:to|for)\s+\w+)\b"#,
            #"(?i)\b(?:kill\s+for\s+a)\b"#,
            #"(?i)\b(?:to\s+die\s+for)\b"#,
        ]

        var result = text
        for pattern in metaphors {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: ""
                )
            }
        }
        return result
    }
}
