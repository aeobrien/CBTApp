import Foundation
import Domain

/// Builds system prompts and manages conversation formatting for the agent service.
public enum ConversationManager {

    /// Build the system prompt for generating a new CBT protocol.
    public static func buildGenerationSystemPrompt() -> String {
        var parts: [String] = []

        parts.append("""
        You are a CBT protocol builder. Your task is to produce a single JSON object \
        that conforms to the CBTProtocol schema based on the workshop conversation.

        IMPORTANT: Respond with ONLY the JSON object. No commentary, no explanation, \
        no markdown fences — just valid JSON.
        """)

        parts.append(schemaDescription())
        parts.append(enumValues())
        parts.append(interventionLibraryInfo())
        parts.append(constraintRules())

        return parts.joined(separator: "\n\n")
    }

    /// Build the system prompt for revising an existing protocol.
    public static func buildRevisionSystemPrompt(
        existingProtocol: CBTProtocol,
        runHistorySummary: String?
    ) -> String {
        var parts: [String] = []

        parts.append("""
        You are a CBT protocol builder. You are revising an existing protocol \
        named "\(existingProtocol.name)". Output a COMPLETE, updated JSON object — \
        not a diff or partial update.

        IMPORTANT: Respond with ONLY the JSON object. No commentary, no explanation, \
        no markdown fences — just valid JSON.
        """)

        // Include the existing protocol as context
        if let encoded = try? JSONEncoder.prettyPrinted.encode(existingProtocol),
           let json = String(data: encoded, encoding: .utf8) {
            parts.append("CURRENT PROTOCOL:\n\(json)")
        }

        if let summary = runHistorySummary {
            parts.append("RUN HISTORY SUMMARY:\n\(summary)")
        }

        parts.append(schemaDescription())
        parts.append(enumValues())
        parts.append(interventionLibraryInfo())
        parts.append(constraintRules())

        return parts.joined(separator: "\n\n")
    }

    /// Extract JSON from a response that may contain markdown fences or extra text.
    public static func extractJSON(from response: String) -> String? {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strategy 1: the whole string is valid JSON
        if trimmed.hasPrefix("{"), isValidJSON(trimmed) {
            return trimmed
        }

        // Strategy 2: extract from ```json ... ``` fences
        if let fenced = extractFencedJSON(from: trimmed) {
            return fenced
        }

        // Strategy 3: find first { to last }
        if let start = trimmed.firstIndex(of: "{"),
           let end = trimmed.lastIndex(of: "}") {
            let candidate = String(trimmed[start...end])
            if isValidJSON(candidate) {
                return candidate
            }
        }

        return nil
    }

    /// Convert domain ConversationMessages to ChatMessages for the API.
    public static func toChatMessages(
        _ messages: [ConversationMessage],
        systemPrompt: String
    ) -> [ChatMessage] {
        var result = [ChatMessage(role: "system", content: systemPrompt)]
        for message in messages {
            result.append(ChatMessage(role: message.role.rawValue, content: message.content))
        }
        return result
    }

    /// Build a repair message containing validation errors.
    public static func buildRepairMessage(errors: [String]) -> String {
        var message = "The JSON you produced failed validation with the following errors:\n"
        for (index, error) in errors.enumerated() {
            message += "\(index + 1). \(error)\n"
        }
        message += "\nPlease fix these issues and output the corrected JSON object. Respond with ONLY the JSON."
        return message
    }

    // MARK: - Private

    private static func schemaDescription() -> String {
        """
        SCHEMA — CBTProtocol JSON object:

        REQUIRED FIELDS:
        - id: String (UUID format)
        - version: String (semantic version, e.g. "1.0.0")
        - name: String (non-empty)
        - summary: String (non-empty)
        - status: String (enum, see below)
        - whenToUse: [String] (at least 1 entry, each ≤ 80 chars)
        - hotThoughtTemplates: [String]
        - maintainingBehaviours: [{id: UUID, type: String (enum), description: String, shortTermRelief: String, longTermCost: String}]
        - targets: {targetBelief: String (non-empty), targetLoop: String? (enum)}
        - captureFields: [{id: UUID, fieldType: String (enum), label: String, isRequired: Bool}]
        - interventions: [{id: UUID, interventionID: String (must be valid library ID), type: String (enum), title: String, script: String (≤ 240 chars), steps: [String], durationEstimate: Int (> 0), isTimed: Bool}] (at least 1)
        - experiments: [{id: UUID, prediction: String (non-empty), steps: [String] (non-empty), measures: [String], successCriteria: String (non-empty), outcomes: []}]
        - measures: [String]
        - reviewRules: [{id: UUID, condition: String, action: String}]
        - safety: {message: String (non-empty), resources: [{id: UUID, name: String, detail: String, phoneNumber: String?, url: String?}] (at least 1)}
        - formulation: {triggerAppraisalLinks: [{id: UUID, trigger: String, appraisal: String, emotion: String (enum), behaviour: String (enum)}], maintainingCycles: [{id: UUID, behaviour: String (enum), shortTermFunction: String, longTermCost: String, targetInterventionID: String?}]}

        OPTIONAL FIELDS:
        - tags: [String]
        - exclusions: [String]
        - tone: String?
        - defaults: {defaultEmotionIntensity: Int? (0-100), defaultBeliefStrength: Int? (0-100), recommendedInterventionID: String? (valid library ID)}?
        - standardisedMeasures: [{id: UUID, measureID: String, frequency: String (enum), lastAdministered: Date?, scores: []}]
        - escalationRules: [{id: UUID, trigger: String, action: String}]
        - completionSummary: String?
        - relapsePreventionCard: {keyTrigger: String, updatedBelief: String, bestInterventionID: String (valid library ID), bestInterventionTitle: String, summaryNote: String}?

        METADATA:
        - createdAt: String (ISO 8601 date)
        - updatedAt: String (ISO 8601 date)
        """
    }

    private static func enumValues() -> String {
        var parts = ["ENUM VALUES:"]

        parts.append("ProtocolStatus: \(ProtocolStatus.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("InterventionType: \(InterventionType.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("EmotionType: \(EmotionType.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("UrgeType: \(UrgeType.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("BodySignal: \(BodySignal.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("MaintainingBehaviourType: \(MaintainingBehaviourType.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("TargetLoopType: \(TargetLoopType.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("CaptureFieldType: \(CaptureFieldType.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("MeasureFrequency: \(MeasureFrequency.allCases.map(\.rawValue).joined(separator: ", "))")
        parts.append("OutcomeTag: \(OutcomeTag.allCases.map(\.rawValue).joined(separator: ", "))")

        return parts.joined(separator: "\n")
    }

    private static func interventionLibraryInfo() -> String {
        var parts = ["VALID INTERVENTION LIBRARY IDs (interventionID must be one of these):"]

        for template in InterventionLibrary.allTemplates {
            parts.append("- \(template.id) (\(template.name), type: \(template.type.rawValue))")
        }

        return parts.joined(separator: "\n")
    }

    private static func constraintRules() -> String {
        """
        CONSTRAINT RULES:
        - interventions[].script must be ≤ 240 characters
        - whenToUse[] entries must be ≤ 80 characters each
        - interventions[].interventionID must be a valid library ID from the list above
        - interventions[].durationEstimate must be > 0
        - defaults.defaultEmotionIntensity must be 0-100 if present
        - defaults.defaultBeliefStrength must be 0-100 if present
        - defaults.recommendedInterventionID must be a valid library ID if present
        - relapsePreventionCard.bestInterventionID must be a valid library ID if present
        - formulation.maintainingCycles[].targetInterventionID must be a valid library ID if present
        - safety.message must be non-empty
        - safety.resources must have at least 1 entry
        - targets.targetBelief must be non-empty
        - At least 1 intervention required
        - Do NOT include medical dosage language (e.g. "prescribe 20mg") in any text field
        """
    }

    /// Extract a human-readable description from a DecodingError for repair messages.
    public static func decodingErrorDetail(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else {
            return error.localizedDescription
        }
        switch decodingError {
        case .keyNotFound(let key, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            let location = path.isEmpty ? "root" : path
            return "Missing required key '\(key.stringValue)' at \(location)"
        case .typeMismatch(let type, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return "Type mismatch at '\(path)': expected \(type), \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return "Null value at '\(path)': expected \(type)"
        case .dataCorrupted(let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return "Data corrupted at '\(path)': \(context.debugDescription)"
        @unknown default:
            return error.localizedDescription
        }
    }

    private static func isValidJSON(_ string: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    private static func extractFencedJSON(from text: String) -> String? {
        // Match ```json ... ``` or ``` ... ```
        let patterns = ["```json\n", "```\n"]
        for pattern in patterns {
            guard let startRange = text.range(of: pattern) else { continue }
            let afterFence = text[startRange.upperBound...]
            guard let endRange = afterFence.range(of: "```") else { continue }
            let content = String(afterFence[..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            if isValidJSON(content) {
                return content
            }
        }
        return nil
    }
}

// MARK: - JSONEncoder convenience

private extension JSONEncoder {
    static let prettyPrinted: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
