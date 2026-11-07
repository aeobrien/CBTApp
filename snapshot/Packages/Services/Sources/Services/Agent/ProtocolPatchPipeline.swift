import Foundation
import Domain
import Utilities

/// Revises an existing CBT protocol via the LLM with validation and repair.
public actor ProtocolPatchPipeline {

    private let apiClient: OpenAIAPIClient
    private let logger = CBTLogger.logger(for: .agentService)
    private let maxRepairAttempts: Int

    public init(apiClient: OpenAIAPIClient, maxRepairAttempts: Int = 3) {
        self.apiClient = apiClient
        self.maxRepairAttempts = maxRepairAttempts
    }

    /// Revise an existing protocol. Preserves the original ID and increments the version.
    public func revise(
        existing: CBTProtocol,
        context: GenerationContext,
        correlationID: String? = nil
    ) async -> AgentResult {
        let systemPrompt = ConversationManager.buildRevisionSystemPrompt(
            existingProtocol: existing,
            runHistorySummary: context.runHistorySummary
        )
        var chatMessages = ConversationManager.toChatMessages(context.workshopMessages, systemPrompt: systemPrompt)

        logger.debug("Starting revision pipeline for '\(existing.name)'", correlationID: correlationID)

        for attempt in 0..<maxRepairAttempts {
            let responseContent: String
            do {
                responseContent = try await apiClient.sendChatCompletion(
                    messages: chatMessages,
                    jsonMode: true,
                    correlationID: correlationID
                )
            } catch {
                logger.error("API call failed during revision: \(error.localizedDescription)",
                           correlationID: correlationID)
                return .networkError(error.localizedDescription)
            }

            let result = decodeAndValidate(
                response: responseContent,
                existing: existing,
                attempt: attempt,
                correlationID: correlationID
            )

            switch result {
            case .success(var proto):
                // Preserve original ID, increment version, update timestamp
                proto.id = existing.id
                proto.version = Self.incrementVersion(existing.version)
                proto.updatedAt = Date()
                logger.info("Revision succeeded on attempt \(attempt + 1)", correlationID: correlationID)
                return .success(proto)

            case .needsRepair(let errors):
                if attempt < maxRepairAttempts - 1 {
                    let repairMessage = ConversationManager.buildRepairMessage(errors: errors)
                    chatMessages.append(ChatMessage(role: "assistant", content: responseContent))
                    chatMessages.append(ChatMessage(role: "user", content: repairMessage))
                    logger.debug("Revision repair attempt \(attempt + 1): \(errors.count) error(s)",
                               correlationID: correlationID)
                } else {
                    logger.error("Revision repair limit exceeded", correlationID: correlationID)
                    return .repairFailed(errors: errors)
                }

            case .networkError(let message):
                return .networkError(message)
            }
        }

        return .repairFailed(errors: ["Exceeded maximum repair attempts"])
    }

    /// Increment the minor version: "1.0.0" → "1.1.0", "2.3.1" → "2.4.0"
    public static func incrementVersion(_ version: String) -> String {
        let components = version.split(separator: ".").compactMap { Int($0) }
        guard components.count == 3 else { return version }
        return "\(components[0]).\(components[1] + 1).0"
    }

    // MARK: - Private

    private enum DecodeResult {
        case success(CBTProtocol)
        case needsRepair([String])
        case networkError(String)
    }

    private func decodeAndValidate(
        response: String,
        existing: CBTProtocol,
        attempt: Int,
        correlationID: String?
    ) -> DecodeResult {
        guard let jsonString = ConversationManager.extractJSON(from: response) else {
            logger.debug("JSON extraction failed on revision attempt \(attempt + 1)", correlationID: correlationID)
            return .needsRepair(["Could not extract valid JSON from response. Respond with ONLY a JSON object."])
        }

        guard let data = jsonString.data(using: .utf8) else {
            return .needsRepair(["Response contained invalid UTF-8 data."])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let proto: CBTProtocol
        do {
            proto = try decoder.decode(CBTProtocol.self, from: data)
        } catch {
            let detail = ConversationManager.decodingErrorDetail(error)
            logger.debug("Revision decoding failed: \(detail)", correlationID: correlationID)
            return .needsRepair(["JSON decoding failed: \(detail)"])
        }

        let validationResult = ValidationPipeline.validate(proto)
        if validationResult.isValid {
            return .success(proto)
        }

        let errorMessages = validationResult.errors.map { "[\($0.fieldPath)] \($0.errorType.rawValue): \($0.message)" }
        return .needsRepair(errorMessages)
    }
}
