import Foundation

// MARK: - Request types

/// A chat completion request sent to the OpenAI API.
struct ChatCompletionRequest: Codable, Sendable {
    var model: String
    var messages: [ChatMessage]
    var responseFormat: ResponseFormat?
    var temperature: Double?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case responseFormat = "response_format"
    }
}

/// A single message in the chat completion request.
public struct ChatMessage: Codable, Sendable {
    public var role: String
    public var content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

/// The response format parameter for JSON mode.
struct ResponseFormat: Codable, Sendable {
    var type: String

    static let jsonObject = ResponseFormat(type: "json_object")
}

// MARK: - Response types

/// The top-level response from the chat completions endpoint.
struct ChatCompletionResponse: Codable, Sendable {
    var id: String
    var choices: [Choice]
    var usage: Usage?
}

/// A single choice in the completion response.
struct Choice: Codable, Sendable {
    var index: Int
    var message: ResponseMessage
    var finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

/// The message content within a choice.
struct ResponseMessage: Codable, Sendable {
    var role: String
    var content: String?
}

/// Token usage statistics.
struct Usage: Codable, Sendable {
    var promptTokens: Int
    var completionTokens: Int
    var totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Error response

/// The error object returned by the OpenAI API on failure.
struct OpenAIErrorResponse: Codable, Sendable {
    var error: OpenAIErrorDetail
}

struct OpenAIErrorDetail: Codable, Sendable {
    var message: String
    var type: String?
    var code: String?
}
