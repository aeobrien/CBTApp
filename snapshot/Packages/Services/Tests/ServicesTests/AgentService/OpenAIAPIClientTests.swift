import Testing
import Foundation
@testable import Services
@testable import Domain

@Suite("OpenAIAPIClient")
struct OpenAIAPIClientTests {

    private func makeClient(
        session: MockURLSession,
        apiKey: String = "test-key"
    ) -> OpenAIAPIClient {
        OpenAIAPIClient(
            session: session,
            apiKeyOverride: apiKey,
            model: "gpt-4o",
            maxRetries: 3
        )
    }

    @Test("Successful response is decoded correctly")
    func successfulResponse() async throws {
        let session = MockURLSession()
        session.enqueueSuccess(content: "Hello, world!")
        let client = makeClient(session: session)

        let result = try await client.sendChatCompletion(
            messages: [ChatMessage(role: "user", content: "Hi")]
        )

        #expect(result == "Hello, world!")
    }

    @Test("Request includes Authorization header and Content-Type")
    func requestHeaders() async throws {
        let session = MockURLSession()
        session.enqueueSuccess(content: "OK")
        let client = makeClient(session: session, apiKey: "sk-test-123")

        _ = try await client.sendChatCompletion(
            messages: [ChatMessage(role: "user", content: "Hi")]
        )

        let request = session.requests.first
        #expect(request?.value(forHTTPHeaderField: "Authorization") == "Bearer sk-test-123")
        #expect(request?.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("JSON mode flag is included in request body")
    func jsonModeFlag() async throws {
        let session = MockURLSession()
        session.enqueueSuccess(content: "{}")
        let client = makeClient(session: session)

        _ = try await client.sendChatCompletion(
            messages: [ChatMessage(role: "user", content: "Generate")],
            jsonMode: true
        )

        let request = session.requests.first
        let body = request?.httpBody.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        let responseFormat = body?["response_format"] as? [String: String]
        #expect(responseFormat?["type"] == "json_object")
    }

    @Test("429 rate limit retries then succeeds")
    func rateLimitRetry() async throws {
        let session = MockURLSession()
        session.enqueueError(statusCode: 429, message: "Rate limited")
        session.enqueueSuccess(content: "Success after retry")
        let client = makeClient(session: session)

        let result = try await client.sendChatCompletion(
            messages: [ChatMessage(role: "user", content: "Hi")]
        )

        #expect(result == "Success after retry")
        #expect(session.requests.count == 2)
    }

    @Test("Timeout error is thrown on URLError.timedOut")
    func timeoutError() async throws {
        let session = MockURLSession()
        session.errorToThrow = URLError(.timedOut)
        let client = OpenAIAPIClient(
            session: session,
            apiKeyOverride: "test-key",
            maxRetries: 1
        )

        await #expect(throws: AgentServiceError.self) {
            _ = try await client.sendChatCompletion(
                messages: [ChatMessage(role: "user", content: "Hi")]
            )
        }
    }

    @Test("Malformed response body throws invalidResponse")
    func malformedResponse() async throws {
        let session = MockURLSession()
        session.enqueueRaw(data: Data("not json".utf8), statusCode: 200)
        let client = OpenAIAPIClient(
            session: session,
            apiKeyOverride: "test-key",
            maxRetries: 1
        )

        await #expect(throws: Error.self) {
            _ = try await client.sendChatCompletion(
                messages: [ChatMessage(role: "user", content: "Hi")]
            )
        }
    }

    @Test("Missing API key throws missingAPIKey")
    func missingAPIKey() async throws {
        let session = MockURLSession()
        let client = OpenAIAPIClient(
            session: session,
            apiKeyOverride: nil,
            maxRetries: 1
        )
        // No keychain key will be found in test environment
        await #expect(throws: AgentServiceError.self) {
            _ = try await client.sendChatCompletion(
                messages: [ChatMessage(role: "user", content: "Hi")]
            )
        }
    }

    @Test("Server error retries then succeeds")
    func serverErrorRetry() async throws {
        let session = MockURLSession()
        session.enqueueError(statusCode: 500, message: "Internal Server Error")
        session.enqueueSuccess(content: "Recovered")
        let client = makeClient(session: session)

        let result = try await client.sendChatCompletion(
            messages: [ChatMessage(role: "user", content: "Hi")]
        )

        #expect(result == "Recovered")
        #expect(session.requests.count == 2)
    }
}
