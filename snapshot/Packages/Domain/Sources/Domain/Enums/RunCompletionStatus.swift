import Foundation

/// Completion status of a single Run.
public enum RunCompletionStatus: String, Codable, Sendable, CaseIterable, Identifiable {
    case completed
    case partialSkippedCapture = "partial_skipped_capture"
    case partialSkippedDiscovery = "partial_skipped_discovery"
    case partialSkippedSummary = "partial_skipped_summary"
    case abandoned

    public var id: String { rawValue }

    public var isComplete: Bool {
        switch self {
        case .completed, .partialSkippedCapture, .partialSkippedDiscovery, .partialSkippedSummary:
            true
        case .abandoned:
            false
        }
    }
}
