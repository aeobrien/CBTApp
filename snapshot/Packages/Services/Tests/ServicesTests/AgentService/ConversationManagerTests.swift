import Testing
import Foundation
@testable import Services
@testable import Domain

@Suite("ConversationManager")
struct ConversationManagerTests {

    @Test("System prompt contains all InterventionType raw values")
    func systemPromptContainsInterventionTypes() {
        let prompt = ConversationManager.buildGenerationSystemPrompt()
        for type in InterventionType.allCases {
            #expect(prompt.contains(type.rawValue),
                   "System prompt should contain InterventionType '\(type.rawValue)'")
        }
    }

    @Test("System prompt contains all intervention library IDs")
    func systemPromptContainsLibraryIDs() {
        let prompt = ConversationManager.buildGenerationSystemPrompt()
        for template in InterventionLibrary.allTemplates {
            #expect(prompt.contains(template.id),
                   "System prompt should contain library ID '\(template.id)'")
        }
    }

    @Test("System prompt contains constraint numbers 240 and 80")
    func systemPromptContainsConstraintNumbers() {
        let prompt = ConversationManager.buildGenerationSystemPrompt()
        #expect(prompt.contains("240"))
        #expect(prompt.contains("80"))
    }

    @Test("JSON extraction: clean JSON is extracted")
    func extractCleanJSON() {
        let json = #"{"name": "Test Protocol"}"#
        let result = ConversationManager.extractJSON(from: json)
        #expect(result == json)
    }

    @Test("JSON extraction: fenced code block is extracted")
    func extractFencedJSON() {
        let input = """
        Here is the protocol:
        ```json
        {"name": "Test Protocol"}
        ```
        """
        let result = ConversationManager.extractJSON(from: input)
        #expect(result == #"{"name": "Test Protocol"}"#)
    }

    @Test("JSON extraction: no JSON returns nil")
    func extractNoJSON() {
        let input = "This is just plain text with no JSON at all."
        let result = ConversationManager.extractJSON(from: input)
        #expect(result == nil)
    }

    @Test("Revision system prompt contains existing protocol name")
    func revisionPromptContainsProtocolName() {
        let proto = CBTProtocol(name: "Anxiety Protocol", summary: "Test")
        let prompt = ConversationManager.buildRevisionSystemPrompt(
            existingProtocol: proto,
            runHistorySummary: nil
        )
        #expect(prompt.contains("Anxiety Protocol"))
    }

    @Test("toChatMessages prepends system prompt")
    func toChatMessagesAddsSystemPrompt() {
        let messages = [
            ConversationMessage(role: .user, content: "Hello"),
            ConversationMessage(role: .assistant, content: "Hi there")
        ]
        let result = ConversationManager.toChatMessages(messages, systemPrompt: "You are a helper.")
        #expect(result.count == 3)
        #expect(result[0].role == "system")
        #expect(result[0].content == "You are a helper.")
        #expect(result[1].role == "user")
        #expect(result[2].role == "assistant")
    }
}
