import Foundation

/// Fixed list of urge/behaviour types for Run capture.
public enum UrgeType: String, Codable, Sendable, CaseIterable, Identifiable {
    case ruminate
    case check
    case avoid
    case scroll
    case overwork = "work"
    case argue
    case distract
    case reassuranceSeek = "reassurance_seek"
    case withdraw
    case binge
    case selfCriticise = "self_criticise"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .ruminate: "Ruminate"
        case .check: "Check"
        case .avoid: "Avoid"
        case .scroll: "Scroll"
        case .overwork: "Overwork"
        case .argue: "Argue internally"
        case .distract: "Distract"
        case .reassuranceSeek: "Seek reassurance"
        case .withdraw: "Withdraw"
        case .binge: "Binge"
        case .selfCriticise: "Self-criticise"
        }
    }
}
