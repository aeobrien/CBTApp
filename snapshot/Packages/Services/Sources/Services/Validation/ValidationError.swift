import Foundation

/// The category of a validation error.
public enum ValidationErrorType: String, Sendable {
    case missingRequired
    case invalidValue
    case constraintViolation
    case invalidReference
    case contentPolicy
}

/// A single validation error with a field path for agent repair feedback.
public struct ValidationError: Sendable, Equatable {
    public var fieldPath: String
    public var errorType: ValidationErrorType
    public var message: String

    public init(fieldPath: String, errorType: ValidationErrorType, message: String) {
        self.fieldPath = fieldPath
        self.errorType = errorType
        self.message = message
    }
}

/// The result of running the validation pipeline on a protocol.
public struct ValidationResult: Sendable {
    public var errors: [ValidationError]
    public var isValid: Bool { errors.isEmpty }

    public init(errors: [ValidationError] = []) {
        self.errors = errors
    }
}
