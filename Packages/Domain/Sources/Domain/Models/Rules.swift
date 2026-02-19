import Foundation

/// A rule that determines when to prompt protocol review/revision.
public struct ReviewRule: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var condition: String
    public var action: String

    public init(
        id: UUID = UUID(),
        condition: String,
        action: String
    ) {
        self.id = id
        self.condition = condition
        self.action = action
    }
}

/// A rule that triggers escalation (stepped-care logic).
public struct EscalationRule: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var trigger: String
    public var action: String

    public init(
        id: UUID = UUID(),
        trigger: String,
        action: String
    ) {
        self.id = id
        self.trigger = trigger
        self.action = action
    }
}
