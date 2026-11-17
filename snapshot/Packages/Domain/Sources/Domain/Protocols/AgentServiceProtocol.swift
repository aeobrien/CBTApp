import Foundation

/// The result of an agent generation or revision attempt.
public enum AgentResult: Sendable {
    case success(CBTProtocol)
    case repairFailed(errors: [String])
    case networkError(String)
}

/// A single message in a conversation with the agent.
public struct ConversationMessage: Codable, Sendable, Equatable {
    public enum Role: String, Codable, Sendable {
        case system
        case user
        case assistant
    }

    public var role: Role
    public var content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

/// Context provided to the agent for protocol generation or revision.
public struct GenerationContext: Sendable {
    /// The conversation history from the workshop.
    public var workshopMessages: [ConversationMessage]
    /// If non-nil, this is a revision of an existing protocol.
    public var existingProtocol: CBTProtocol?
    /// Optional summary of run history to inform revisions.
    public var runHistorySummary: String?

    public init(
        workshopMessages: [ConversationMessage] = [],
        existingProtocol: CBTProtocol? = nil,
        runHistorySummary: String? = nil
    ) {
        self.workshopMessages = workshopMessages
        self.existingProtocol = existingProtocol
        self.runHistorySummary = runHistorySummary
    }
}

/// Protocol for the agent service that generates and revises CBT protocols via LLM.
public protocol AgentServiceProtocol: Sendable {
    /// Send a raw message and get a response (for workshop conversation).
    func sendMessage(
        _ message: String,
        conversationHistory: [ConversationMessage],
        systemPrompt: String
    ) async throws -> String

    /// Generate a new CBT protocol from workshop conversation context.
    func generateProtocol(context: GenerationContext) async throws -> AgentResult

    /// Revise an existing CBT protocol based on new context.
    func reviseProtocol(
        existing: CBTProtocol,
        context: GenerationContext
    ) async throws -> AgentResult
}
