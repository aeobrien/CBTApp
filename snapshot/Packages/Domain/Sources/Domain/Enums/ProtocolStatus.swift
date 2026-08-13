import Foundation

/// Lifecycle status of a CBT protocol.
public enum ProtocolStatus: String, Codable, Sendable, CaseIterable, Identifiable {
    case active
    case paused
    case completed
    case archived

    public var id: String { rawValue }

    public var displayName: String {
        rawValue.capitalized
    }
}
