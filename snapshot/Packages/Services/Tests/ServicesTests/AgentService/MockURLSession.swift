import Foundation
@testable import Services

/// Mock URL session for testing OpenAIAPIClient without real network calls.
final class MockURLSession: URLSessionProtocol, @unchecked Sendable {

    /// Queue of responses to return, in order.
    var responses: [(Data, HTTPURLResponse)] = []
    private var responseIndex = 0

    /// All requests that were sent.
    private(set) var requests: [URLRequest] = []

    /// Error to throw instead of returning a response.
    var errorToThrow: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)

        if let error = errorToThrow {
            throw error
        }

        guard responseIndex < responses.count else {
            throw URLError(.badServerResponse)
        }

        let response = responses[responseIndex]
        responseIndex += 1
        return response
    }

    // MARK: - Helpers

    /// Enqueue a successful chat completion response.
    func enqueueSuccess(content: String, statusCode: Int = 200) {
        let response = ChatCompletionResponse(
            id: "chatcmpl-test",
            choices: [
                Choice(
                    index: 0,
                    message: ResponseMessage(role: "assistant", content: content),
                    finishReason: "stop"
                )
            ],
            usage: Usage(promptTokens: 100, completionTokens: 50, totalTokens: 150)
        )
        let data = try! JSONEncoder().encode(response)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        responses.append((data, httpResponse))
    }

    /// Enqueue an error response with a given status code.
    func enqueueError(statusCode: Int, message: String = "Error") {
        let errorResponse = OpenAIErrorResponse(
            error: OpenAIErrorDetail(message: message, type: "error", code: nil)
        )
        let data = try! JSONEncoder().encode(errorResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        responses.append((data, httpResponse))
    }

    /// Enqueue a raw data response with a given status code.
    func enqueueRaw(data: Data, statusCode: Int) {
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        responses.append((data, httpResponse))
    }
}
