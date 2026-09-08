import Foundation

/// Parameterises an intervention template with user-specific context
/// to produce a concrete InterventionInstance.
public enum InterventionParameteriser {

    /// Maximum script length for parameterised interventions.
    public static let maxScriptLength = 240

    /// Context provided by the user/run for parameterisation.
    public struct Context: Sendable {
        public var hotThought: String?
        public var prediction: String?
        public var targetBelief: String?
        public var targetSituation: String?
        public var urgeBehaviour: String?

        public init(
            hotThought: String? = nil,
            prediction: String? = nil,
            targetBelief: String? = nil,
            targetSituation: String? = nil,
            urgeBehaviour: String? = nil
        ) {
            self.hotThought = hotThought
            self.prediction = prediction
            self.targetBelief = targetBelief
            self.targetSituation = targetSituation
            self.urgeBehaviour = urgeBehaviour
        }
    }

    /// Parameterise a template with the given context.
    ///
    /// Selects the first example script, substitutes placeholders,
    /// and truncates to the character limit if needed.
    public static func parameterise(
        template: InterventionTemplate,
        context: Context
    ) -> InterventionInstance {
        let rawScript = template.exampleScripts.first ?? template.name
        let script = substituteAndTruncate(rawScript, context: context)

        return InterventionInstance(
            interventionID: template.id,
            type: template.type,
            title: template.name,
            script: script,
            steps: template.steps,
            durationEstimate: template.durationEstimate,
            isTimed: template.type.isTimed
        )
    }

    /// Substitute placeholders and enforce the character limit.
    ///
    /// Lowercases the first character of substituted values because
    /// placeholders appear mid-sentence in scripts.
    static func substituteAndTruncate(_ script: String, context: Context) -> String {
        var result = script

        if let hotThought = context.hotThought {
            result = result.replacingOccurrences(of: "{{hotThought}}", with: lowercaseFirst(hotThought))
        }
        if let prediction = context.prediction {
            result = result.replacingOccurrences(of: "{{prediction}}", with: lowercaseFirst(prediction))
        }
        if let targetBelief = context.targetBelief {
            result = result.replacingOccurrences(of: "{{targetBelief}}", with: lowercaseFirst(targetBelief))
        }
        if let targetSituation = context.targetSituation {
            result = result.replacingOccurrences(of: "{{targetSituation}}", with: lowercaseFirst(targetSituation))
        }
        if let urgeBehaviour = context.urgeBehaviour {
            result = result.replacingOccurrences(of: "{{urgeBehaviour}}", with: lowercaseFirst(urgeBehaviour))
        }

        // Remove any unsubstituted placeholders
        result = result.replacingOccurrences(
            of: "\\{\\{\\w+\\}\\}",
            with: "...",
            options: .regularExpression
        )

        if result.count > maxScriptLength {
            let truncated = String(result.prefix(maxScriptLength - 3))
            // Try to break at a word boundary
            if let lastSpace = truncated.lastIndex(of: " ") {
                result = String(truncated[truncated.startIndex..<lastSpace]) + "..."
            } else {
                result = truncated + "..."
            }
        }

        return result
    }

    /// Lowercase the first character of a string.
    /// Input fields auto-capitalise the first letter, but placeholders
    /// sit mid-sentence so we need lowercase there.
    private static func lowercaseFirst(_ string: String) -> String {
        guard let first = string.first else { return string }
        return first.lowercased() + string.dropFirst()
    }

    /// Returns the set of placeholder names used in a template's example scripts.
    public static func placeholders(in template: InterventionTemplate) -> Set<String> {
        let pattern = "\\{\\{(\\w+)\\}\\}"
        var result = Set<String>()
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        for script in template.exampleScripts {
            let matches = regex.matches(in: script, range: NSRange(script.startIndex..., in: script))
            for match in matches {
                if let range = Range(match.range(at: 1), in: script) {
                    result.insert(String(script[range]))
                }
            }
        }
        return result
    }
}

// MARK: - InterventionType timed support

extension InterventionType {
    /// Whether interventions of this type typically use a timer.
    public var isTimed: Bool {
        switch self {
        case .defusion, .delayExperiment, .ruminationScheduling:
            true
        default:
            false
        }
    }
}
