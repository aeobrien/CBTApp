import Foundation

/// The type of cognitive/behavioural loop being targeted.
public enum TargetLoopType: String, Codable, Sendable, CaseIterable, Identifiable {
    case rumination
    case avoidance
    case checking
    case reassurance
    case perfectionism
    case socialComparison = "social_comparison"
    case catastrophising
    case selfCriticism = "self_criticism"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .rumination: "Rumination"
        case .avoidance: "Avoidance"
        case .checking: "Checking"
        case .reassurance: "Reassurance"
        case .perfectionism: "Perfectionism"
        case .socialComparison: "Social comparison"
        case .catastrophising: "Catastrophising"
        case .selfCriticism: "Self-criticism"
        }
    }
}
