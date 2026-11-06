import Foundation
import Domain
import Utilities

/// Top-level implementation of AgentServiceProtocol using the OpenAI API.
public final class OpenAIAgentService: AgentServiceProtocol, @unchecked Sendable {

    private let apiClient: OpenAIAPIClient
    private let generationPipeline: ProtocolGenerationPipeline
    private let patchPipeline: ProtocolPatchPipeline
    private let logger = CBTLogger.logger(for: .agentService)

    public init(
        apiClient: OpenAIAPIClient
    ) {
        self.apiClient = apiClient
        self.generationPipeline = ProtocolGenerationPipeline(apiClient: apiClient)
        self.patchPipeline = ProtocolPatchPipeline(apiClient: apiClient)
    }

    public func sendMessage(
        _ message: String,
        conversationHistory: [ConversationMessage],
        systemPrompt: String
    ) async throws -> String {
        let correlationID = String(UUID().uuidString.prefix(8).lowercased())
        logger.debug("sendMessage called", correlationID: correlationID)

        var chatMessages = ConversationManager.toChatMessages(conversationHistory, systemPrompt: systemPrompt)
        chatMessages.append(ChatMessage(role: "user", content: message))

        return try await apiClient.sendChatCompletion(
            messages: chatMessages,
            jsonMode: false,
            correlationID: correlationID
        )
    }

    public func generateProtocol(context: GenerationContext) async throws -> AgentResult {
        let correlationID = String(UUID().uuidString.prefix(8).lowercased())
        logger.info("generateProtocol called", correlationID: correlationID)
        return await generationPipeline.generate(context: context, correlationID: correlationID)
    }

    public func reviseProtocol(
        existing: CBTProtocol,
        context: GenerationContext
    ) async throws -> AgentResult {
        let correlationID = String(UUID().uuidString.prefix(8).lowercased())
        logger.info("reviseProtocol called for '\(existing.name)'", correlationID: correlationID)
        return await patchPipeline.revise(existing: existing, context: context, correlationID: correlationID)
    }
}
