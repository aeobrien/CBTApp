import Foundation

/// Navigation steps in the Run Mode flow.
///
/// Each case maps to a screen in the run flow coordinator.
/// Conforms to `Hashable` so it can be used with `NavigationStack(path:)`.
public enum RunFlowStep: String, Codable, Sendable, Hashable, CaseIterable {
    case protocolSelection = "protocol_selection"
    case capture
    case guidedDiscovery = "guided_discovery"
    case intervention
    case outcome
    case summary
}
