import Foundation
import Domain

/// Scans text fields for content that violates safety policies.
enum ContentPolicyValidator {

    /// Regex patterns that indicate medical instruction content.
    private static let medicalPatterns: [(pattern: String, description: String)] = [
        (#"(?i)\bprescribe\b"#, "medical prescription language"),
        (#"(?i)\bdosage\b"#, "dosage instructions"),
        (#"(?i)\bmedication\b"#, "medication references"),
        (#"(?i)\d+\s*mg\b"#, "milligram dosage"),
        (#"(?i)\bmilligrams?\b"#, "milligram dosage"),
        (#"(?i)\btake\s+\d+\s+pills?\b"#, "pill instructions"),
    ]

    /// Regex patterns that indicate harmful content.
    private static let harmfulPatterns: [(pattern: String, description: String)] = [
        (#"(?i)\bself[- ]?harm\s+instructions?\b"#, "self-harm instructions"),
        (#"(?i)\bsuicide\s+method\b"#, "suicide method instructions"),
        (#"(?i)\bhow\s+to\s+(kill|harm)\s+(yourself|myself)\b"#, "harmful instructions"),
    ]

    static func validate(_ protocol: CBTProtocol) -> [ValidationError] {
        var errors: [ValidationError] = []

        // Collect all text fields to scan with their field paths
        var fieldsToScan: [(path: String, text: String)] = [
            ("name", `protocol`.name),
            ("summary", `protocol`.summary),
            ("safety.message", `protocol`.safety.message),
        ]

        for (index, entry) in `protocol`.whenToUse.enumerated() {
            fieldsToScan.append(("whenToUse[\(index)]", entry))
        }

        for (index, thought) in `protocol`.hotThoughtTemplates.enumerated() {
            fieldsToScan.append(("hotThoughtTemplates[\(index)]", thought))
        }

        for (index, intervention) in `protocol`.interventions.enumerated() {
            fieldsToScan.append(("interventions[\(index)].script", intervention.script))
        }

        // Scan each field against all patterns
        for (path, text) in fieldsToScan {
            for (pattern, description) in medicalPatterns {
                if text.range(of: pattern, options: .regularExpression) != nil {
                    errors.append(ValidationError(
                        fieldPath: path,
                        errorType: .contentPolicy,
                        message: "Contains \(description)"
                    ))
                    break // One error per field per category
                }
            }

            for (pattern, description) in harmfulPatterns {
                if text.range(of: pattern, options: .regularExpression) != nil {
                    errors.append(ValidationError(
                        fieldPath: path,
                        errorType: .contentPolicy,
                        message: "Contains \(description)"
                    ))
                    break
                }
            }
        }

        return errors
    }
}
