import Foundation
import Domain
import Utilities
import os

/// Generates a new CBT protocol via the LLM with automatic validation and repair.
public actor ProtocolGenerationPipeline {

    private let apiClient: OpenAIAPIClient
    private let logger = CBTLogger.logger(for: .agentService)
    private let maxRepairAttempts: Int

    public init(apiClient: OpenAIAPIClient, maxRepairAttempts: Int = 3) {
        self.apiClient = apiClient
        self.maxRepairAttempts = maxRepairAttempts
    }

    /// Generate a protocol from the given context. Validates and repairs up to `maxRepairAttempts` times.
    public func generate(
        context: GenerationContext,
        correlationID: String? = nil
    ) async -> AgentResult {
        let systemPrompt = ConversationManager.buildGenerationSystemPrompt()
        var chatMessages = ConversationManager.toChatMessages(context.workshopMessages, systemPrompt: systemPrompt)

        let signpostState = CBTSignpost.begin("GenerateProtocol")
        defer { CBTSignpost.end("GenerateProtocol", signpostState) }

        logger.debug("Starting generation pipeline", correlationID: correlationID)

        for attempt in 0..<maxRepairAttempts {
            let responseContent: String
            do {
                responseContent = try await apiClient.sendChatCompletion(
                    messages: chatMessages,
                    jsonMode: true,
                    correlationID: correlationID
                )
            } catch {
                logger.error("API call failed: \(error.localizedDescription)", correlationID: correlationID)
                return .networkError(error.localizedDescription)
            }

            // Extract and decode
            let result = decodeAndValidate(
                response: responseContent,
                attempt: attempt,
                correlationID: correlationID
            )

            switch result {
            case .success(var proto):
                // Set metadata
                let now = Date()
                proto.createdAt = now
                proto.updatedAt = now
                proto.status = .active
                logger.info("Generation succeeded on attempt \(attempt + 1)", correlationID: correlationID)
                return .success(proto)

            case .needsRepair(let errors):
                if attempt < maxRepairAttempts - 1 {
                    let repairMessage = ConversationManager.buildRepairMessage(errors: errors)
                    chatMessages.append(ChatMessage(role: "assistant", content: responseContent))
                    chatMessages.append(ChatMessage(role: "user", content: repairMessage))
                    logger.debug("Repair attempt \(attempt + 1): \(errors.count) error(s)", correlationID: correlationID)
                } else {
                    logger.error("Repair limit exceeded after \(maxRepairAttempts) attempts", correlationID: correlationID)
                    return .repairFailed(errors: errors)
                }

            case .networkError(let message):
                return .networkError(message)
            }
        }

        return .repairFailed(errors: ["Exceeded maximum repair attempts"])
    }

    // MARK: - Private

    private enum DecodeResult {
        case success(CBTProtocol)
        case needsRepair([String])
        case networkError(String)
    }

    private func decodeAndValidate(
        response: String,
        attempt: Int,
        correlationID: String?
    ) -> DecodeResult {
        // Extract JSON
        guard let jsonString = ConversationManager.extractJSON(from: response) else {
            logger.debug("JSON extraction failed on attempt \(attempt + 1)", correlationID: correlationID)
            return .needsRepair(["Could not extract valid JSON from response. Respond with ONLY a JSON object."])
        }

        // Decode
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
            logger.debug("Decoding failed: \(detail)", correlationID: correlationID)
            return .needsRepair(["JSON decoding failed: \(detail)"])
        }

        // Validate
        let validationResult = ValidationPipeline.validate(proto)
        if validationResult.isValid {
            return .success(proto)
        }

        let errorMessages = validationResult.errors.map { "[\($0.fieldPath)] \($0.errorType.rawValue): \($0.message)" }
        return .needsRepair(errorMessages)
    }
}
