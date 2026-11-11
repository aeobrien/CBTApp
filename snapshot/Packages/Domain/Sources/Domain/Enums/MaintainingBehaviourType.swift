import Foundation

/// Types of maintaining behaviours that keep patterns active.
public enum MaintainingBehaviourType: String, Codable, Sendable, CaseIterable, Identifiable {
    case rumination
    case checking
    case avoidance
    case reassuranceSeeking = "reassurance_seeking"
    case overworking
    case scrolling
    case arguingInternally = "arguing_internally"
    case suppression
    case withdrawal
    case perfectionism
    case procrastination
    case substanceUse = "substance_use"

    public var id: String { rawValue }

    /// Common LLM-generated aliases that map to canonical raw values.
    private static let aliases: [String: MaintainingBehaviourType] = [
        "ruminate": .rumination,
        "ruminat": .rumination,
        "check": .checking,
        "avoid": .avoidance,
        "reassurance_seek": .reassuranceSeeking,
        "reassurance": .reassuranceSeeking,
        "overwork": .overworking,
        "scroll": .scrolling,
        "arguing": .arguingInternally,
        "suppress": .suppression,
        "withdraw": .withdrawal,
        "procrastinate": .procrastination,
        "substance": .substanceUse,
    ]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        if let canonical = MaintainingBehaviourType(rawValue: value) {
            self = canonical
        } else if let aliased = Self.aliases[value] {
            self = aliased
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Cannot initialize MaintainingBehaviourType from invalid String value \(value). Valid values: \(Self.allCases.map(\.rawValue).joined(separator: ", "))")
            )
        }
    }

    public var displayName: String {
        switch self {
        case .rumination: "Rumination"
        case .checking: "Checking"
        case .avoidance: "Avoidance"
        case .reassuranceSeeking: "Reassurance-seeking"
        case .overworking: "Overworking"
        case .scrolling: "Scrolling"
        case .arguingInternally: "Arguing internally"
        case .suppression: "Suppression"
        case .withdrawal: "Withdrawal"
        case .perfectionism: "Perfectionism"
        case .procrastination: "Procrastination"
        case .substanceUse: "Substance use"
        }
    }
}
