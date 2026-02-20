import Foundation

/// Configurable mock for AgentServiceProtocol, for testing and previews.
public final class MockAgentService: AgentServiceProtocol, @unchecked Sendable {

    // MARK: - Configuration

    /// Result to return from `sendMessage`. Defaults to a canned response.
    public var sendMessageResult: Result<String, Error> = .success("Mock agent response")

    /// Result to return from `generateProtocol`.
    public var generateResult: Result<AgentResult, Error>

    /// Result to return from `reviseProtocol`.
    public var reviseResult: Result<AgentResult, Error>

    // MARK: - Call tracking

    public private(set) var sendMessageCallCount = 0
    public private(set) var generateCallCount = 0
    public private(set) var reviseCallCount = 0
    public private(set) var lastGenerationContext: GenerationContext?
    public private(set) var lastRevisionProtocol: CBTProtocol?

    // MARK: - Init

    public init(
        generateResult: Result<AgentResult, Error> = .success(.success(CBTProtocol(name: "Mock Protocol", summary: "A mock protocol"))),
        reviseResult: Result<AgentResult, Error> = .success(.success(CBTProtocol(name: "Revised Protocol", summary: "A revised mock protocol")))
    ) {
        self.generateResult = generateResult
        self.reviseResult = reviseResult
    }

    // MARK: - AgentServiceProtocol

    public func sendMessage(
        _ message: String,
        conversationHistory: [ConversationMessage],
        systemPrompt: String
    ) async throws -> String {
        sendMessageCallCount += 1
        return try sendMessageResult.get()
    }

    public func generateProtocol(context: GenerationContext) async throws -> AgentResult {
        generateCallCount += 1
        lastGenerationContext = context
        return try generateResult.get()
    }

    public func reviseProtocol(
        existing: CBTProtocol,
        context: GenerationContext
    ) async throws -> AgentResult {
        reviseCallCount += 1
        lastRevisionProtocol = existing
        return try reviseResult.get()
    }
}
