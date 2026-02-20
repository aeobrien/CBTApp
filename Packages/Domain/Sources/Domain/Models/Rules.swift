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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        condition = try container.decodeIfPresent(String.self, forKey: .condition) ?? ""
        action = try container.decodeIfPresent(String.self, forKey: .action) ?? ""
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        trigger = try container.decodeIfPresent(String.self, forKey: .trigger) ?? ""
        action = try container.decodeIfPresent(String.self, forKey: .action) ?? ""
    }
}
