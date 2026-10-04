import Foundation

/// Errors that can occur in the agent service layer.
public enum AgentServiceError: Error, Sendable, Equatable {
    case missingAPIKey
    case networkError(String)
    case rateLimited(retryAfter: Int?)
    case timeout
    case invalidResponse(String)
    case jsonExtractionFailed
    case decodingFailed(String)
    case repairLimitExceeded(errors: [String])
    case keychainError(String)
}

extension AgentServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "No API key configured. Please add your OpenAI API key in Settings."
        case .networkError(let message):
            "Network error: \(message)"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                "Rate limited. Retry after \(seconds) seconds."
            } else {
                "Rate limited. Please try again later."
            }
        case .timeout:
            "Request timed out. Please try again."
        case .invalidResponse(let detail):
            "Invalid response from API: \(detail)"
        case .jsonExtractionFailed:
            "Could not extract JSON from the agent's response."
        case .decodingFailed(let detail):
            "Failed to decode protocol: \(detail)"
        case .repairLimitExceeded(let errors):
            "Protocol validation failed after 3 repair attempts. Errors: \(errors.joined(separator: "; "))"
        case .keychainError(let detail):
            "Keychain error: \(detail)"
        }
    }
}
