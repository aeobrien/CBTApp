import os
import Foundation

/// Centralised logging utility for the CBT app.
///
/// Usage:
/// ```swift
/// let logger = CBTLogger.logger(for: .runMode)
/// logger.debug("Entering capture screen", correlationID: runID)
/// logger.info("Run saved successfully", correlationID: runID)
/// logger.error("Validation failed: \(error)", correlationID: runID)
/// ```
///
/// All logs use Apple's `os.Logger` with:
/// - Subsystem: `com.cbt.app`
/// - Category: the module name
///
/// Every log line is prefixed with `[CategoryName]` so you can filter
/// by typing the category name (e.g., `RunMode`, `App`) in Xcode's console filter bar.
public enum CBTLogger {

    /// The shared subsystem identifier for all CBT app logs.
    public static let subsystem = "com.cbt.app"

    /// Known module categories for structured logging.
    public enum Category: String, Sendable {
        case app = "App"
        case domain = "Domain"
        case data = "Data"
        case designSystem = "DesignSystem"
        case services = "Services"
        case utilities = "Utilities"
        case protocolEngine = "ProtocolEngine"
        case runMode = "RunMode"
        case workshop = "Workshop"
        case evidence = "Evidence"
        case agentService = "AgentService"
        case validation = "Validation"
        case safety = "Safety"
        case voiceInput = "VoiceInput"
        case onboarding = "Onboarding"
        case quickTriage = "QuickTriage"
        case settings = "Settings"
    }

    /// Returns a `ModuleLogger` for the given category.
    public static func logger(for category: Category) -> ModuleLogger {
        ModuleLogger(category: category)
    }
}

/// A logger scoped to a specific module category.
///
/// Wraps `os.Logger` and adds correlation ID support for tracing
/// related operations (e.g., all log entries for a single Run).
public struct ModuleLogger: Sendable {

    private let osLogger: Logger

    /// The category this logger is scoped to.
    public let category: CBTLogger.Category

    init(category: CBTLogger.Category) {
        self.category = category
        self.osLogger = Logger(
            subsystem: CBTLogger.subsystem,
            category: category.rawValue
        )
    }

    // MARK: - Debug (flow tracing)

    /// Log at debug level — for flow tracing: entering functions, choosing branches.
    /// Debug logs are stripped in release builds with no performance cost.
    public func debug(_ message: String, correlationID: String? = nil) {
        let formatted = Self.format(message, category: category, correlationID: correlationID)
        osLogger.debug("\(formatted, privacy: .public)")
    }

    // MARK: - Info (state changes)

    /// Log at info level — for state changes: protocol loaded, run saved.
    public func info(_ message: String, correlationID: String? = nil) {
        let formatted = Self.format(message, category: category, correlationID: correlationID)
        osLogger.info("\(formatted, privacy: .public)")
    }

    // MARK: - Warning

    /// Log at notice level — for unexpected but recoverable situations.
    public func warning(_ message: String, correlationID: String? = nil) {
        let formatted = Self.format(message, category: category, correlationID: correlationID)
        osLogger.notice("\(formatted, privacy: .public)")
    }

    // MARK: - Error (failures)

    /// Log at error level — for failures with full context.
    public func error(_ message: String, correlationID: String? = nil) {
        let formatted = Self.format(message, category: category, correlationID: correlationID)
        osLogger.error("\(formatted, privacy: .public)")
    }

    // MARK: - Formatting

    private static func format(_ message: String, category: CBTLogger.Category, correlationID: String?) -> String {
        var result = "[\(category.rawValue)]"
        if let correlationID {
            result += " [\(correlationID)]"
        }
        result += " \(message)"
        return result
    }
}

// MARK: - Performance Instrumentation

/// Lightweight wrapper around `OSSignposter` for Instruments > Points of Interest.
///
/// Usage:
/// ```swift
/// let state = CBTSignpost.begin("GenerateProtocol")
/// // ... work ...
/// CBTSignpost.end("GenerateProtocol", state)
/// ```
public enum CBTSignpost {
    private static let pointsOfInterest = OSSignposter(
        subsystem: CBTLogger.subsystem,
        category: .pointsOfInterest
    )

    public static func begin(_ name: StaticString) -> OSSignpostIntervalState {
        pointsOfInterest.beginInterval(name)
    }

    public static func end(_ name: StaticString, _ state: OSSignpostIntervalState) {
        pointsOfInterest.endInterval(name, state)
    }
}
