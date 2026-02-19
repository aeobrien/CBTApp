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
