import Foundation
import Utilities
import os

/// Protocol for URL session abstraction, enabling test injection.
public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// Actor that handles HTTP communication with the OpenAI chat completions API.
public actor OpenAIAPIClient {

    private let session: URLSessionProtocol
    private let apiKeyOverride: String?
    private let logger = CBTLogger.logger(for: .agentService)
    private let model: String
    private let maxRetries: Int
    private let baseURL: String

    /// A dedicated URLSession with ephemeral config (no stale connection pooling).
    private static let defaultSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    /// Create a new API client.
    /// - Parameters:
    ///   - session: URL session to use (inject mock for tests).
    ///   - apiKeyOverride: If set, used instead of Keychain lookup.
    ///   - model: The OpenAI model ID to use.
    ///   - maxRetries: Maximum retry attempts for transient errors.
    ///   - baseURL: The API base URL.
    public init(
        session: URLSessionProtocol? = nil,
        apiKeyOverride: String? = nil,
        model: String = "gpt-5.2",
        maxRetries: Int = 3,
        baseURL: String = "https://api.openai.com/v1"
    ) {
        self.session = session ?? OpenAIAPIClient.defaultSession
        self.apiKeyOverride = apiKeyOverride
        self.model = model
        self.maxRetries = maxRetries
        self.baseURL = baseURL
    }

    /// Send a chat completion request and return the assistant's response content.
    public func sendChatCompletion(
        messages: [ChatMessage],
        jsonMode: Bool = false,
        correlationID: String? = nil
    ) async throws -> String {
        let apiKey = try resolveAPIKey()

        let request = ChatCompletionRequest(
            model: model,
            messages: messages,
            responseFormat: jsonMode ? .jsonObject : nil,
            temperature: 0.7
        )

        let urlRequest = try buildURLRequest(body: request, apiKey: apiKey)

        let signpostState = CBTSignpost.begin("APIRequest")
        defer { CBTSignpost.end("APIRequest", signpostState) }

        logger.debug("Sending chat completion (\(messages.count) messages, jsonMode=\(jsonMode))",
                     correlationID: correlationID)

        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                let (data, response) = try await session.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AgentServiceError.invalidResponse("Non-HTTP response")
                }

                logger.debug("Response status: \(httpResponse.statusCode), attempt \(attempt + 1)",
                            correlationID: correlationID)

                switch httpResponse.statusCode {
                case 200:
                    return try decodeSuccess(data: data, correlationID: correlationID)

                case 429:
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                        .flatMap(Int.init)
                    lastError = AgentServiceError.rateLimited(retryAfter: retryAfter)
                    if attempt < maxRetries - 1 {
                        let delay = backoffDelay(attempt: attempt)
                        logger.debug("Rate limited, retrying in \(delay)s", correlationID: correlationID)
                        try await Task.sleep(for: .seconds(delay))
                        continue
                    }

                case 500...599:
                    lastError = AgentServiceError.networkError("Server error: \(httpResponse.statusCode)")
                    if attempt < maxRetries - 1 {
                        let delay = backoffDelay(attempt: attempt)
                        logger.debug("Server error \(httpResponse.statusCode), retrying in \(delay)s",
                                    correlationID: correlationID)
                        try await Task.sleep(for: .seconds(delay))
                        continue
                    }

                case 401:
                    throw AgentServiceError.missingAPIKey

                default:
                    let errorDetail = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                    let message = errorDetail?.error.message ?? "HTTP \(httpResponse.statusCode)"
                    throw AgentServiceError.invalidResponse(message)
                }
            } catch let error as AgentServiceError {
                lastError = error
                if case .missingAPIKey = error { throw error }
                if case .invalidResponse = error { throw error }
                // For other AgentServiceErrors, they were already handled above
                if attempt == maxRetries - 1 { break }
            } catch is CancellationError {
                throw AgentServiceError.timeout
            } catch let error as URLError where error.code == .timedOut {
                throw AgentServiceError.timeout
            } catch {
                lastError = AgentServiceError.networkError(error.localizedDescription)
                if attempt == maxRetries - 1 { break }
                let delay = backoffDelay(attempt: attempt)
                try await Task.sleep(for: .seconds(delay))
            }
        }

        if let error = lastError as? AgentServiceError {
            throw error
        }
        throw lastError ?? AgentServiceError.networkError("Unknown error")
    }

    // MARK: - Private

    private func resolveAPIKey() throws -> String {
        if let override = apiKeyOverride { return override }
        guard let key = KeychainHelper.loadAPIKey() else {
            throw AgentServiceError.missingAPIKey
        }
        return key
    }

    private func buildURLRequest(body: ChatCompletionRequest, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw AgentServiceError.invalidResponse("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func decodeSuccess(data: Data, correlationID: String?) throws -> String {
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = response.choices.first?.message.content else {
            throw AgentServiceError.invalidResponse("No content in response")
        }
        if let usage = response.usage {
            logger.debug("Tokens: \(usage.promptTokens) prompt + \(usage.completionTokens) completion = \(usage.totalTokens) total",
                        correlationID: correlationID)
        }
        return content
    }

    /// Exponential backoff with jitter: base * 2^attempt + random(0..<1)
    private func backoffDelay(attempt: Int) -> Double {
        let base = 1.0
        let exponential = base * pow(2.0, Double(attempt))
        let jitter = Double.random(in: 0..<1)
        return exponential + jitter
    }
}
