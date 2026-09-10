import Foundation

/// Fixed list of body signals for Run capture.
public enum BodySignal: String, Codable, Sendable, CaseIterable, Identifiable {
    case tightChest = "tight_chest"
    case tightJaw = "tight_jaw"
    case stomachDrop = "stomach_drop"
    case nausea
    case racingHeart = "racing_heart"
    case shallowBreathing = "shallow_breathing"
    case tension
    case heaviness
    case restlessness
    case numbness
    case heat
    case trembling

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .tightChest: "Tight chest"
        case .tightJaw: "Tight jaw"
        case .stomachDrop: "Stomach drop"
        case .nausea: "Nausea"
        case .racingHeart: "Racing heart"
        case .shallowBreathing: "Shallow breathing"
        case .tension: "Tension"
        case .heaviness: "Heaviness"
        case .restlessness: "Restlessness"
        case .numbness: "Numbness"
        case .heat: "Heat / flushing"
        case .trembling: "Trembling"
        }
    }
}
