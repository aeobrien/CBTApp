import Foundation

/// Multi-select outcome tags for the Run outcome screen.
public enum OutcomeTag: String, Codable, Sendable, CaseIterable, Identifiable {
    case intensityDropped = "intensity_dropped"
    case sameButTolerable = "same_but_tolerable"
    case gotWorse = "got_worse"
    case ruminatedAnyway = "ruminated_anyway"
    case avoided
    case predictionDidntHappen = "prediction_didnt_happen"
    case uncomfortableButTolerable = "uncomfortable_but_tolerable"
    case canHandleMoreThanThought = "can_handle_more_than_thought"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .intensityDropped: "Intensity dropped"
        case .sameButTolerable: "Stayed the same but tolerable"
        case .gotWorse: "Got worse"
        case .ruminatedAnyway: "I ruminated anyway"
        case .avoided: "I avoided"
        case .predictionDidntHappen: "The prediction didn't happen"
        case .uncomfortableButTolerable: "It was uncomfortable but tolerable"
        case .canHandleMoreThanThought: "I can handle more than I thought"
        }
    }
}
