import Foundation

/// The stages of the protocol-building workshop.
///
/// Each stage is a discrete step in the guided discovery process.
/// Stages 2, 3, 4, and 6 use agent-led conversation; the rest
/// are structured input screens.
public enum WorkshopStage: Int, CaseIterable, Sendable, Hashable {
    case capture = 1
    case recurrence = 2
    case maintaining = 3
    case targetBelief = 4
    case interventionSelection = 5
    case experimentDesign = 6
    case captureFields = 7
    case standardisedMeasures = 8
    case reviewRules = 9
    case generation = 10

    /// Human-readable title for the stage.
    public var title: String {
        switch self {
        case .capture: "Capture"
        case .recurrence: "Recurrence"
        case .maintaining: "Maintaining"
        case .targetBelief: "Target Belief"
        case .interventionSelection: "Interventions"
        case .experimentDesign: "Experiment"
        case .captureFields: "Capture Fields"
        case .standardisedMeasures: "Measures"
        case .reviewRules: "Review Rules"
        case .generation: "Generate"
        }
    }

    /// Brief description shown below the title.
    public var subtitle: String {
        switch self {
        case .capture: "Describe the situation and your reaction"
        case .recurrence: "Explore when this pattern recurs"
        case .maintaining: "Identify what keeps the pattern going"
        case .targetBelief: "Articulate the core belief"
        case .interventionSelection: "Choose evidence-based interventions"
        case .experimentDesign: "Design a behavioural experiment"
        case .captureFields: "Configure what to capture during runs"
        case .standardisedMeasures: "Select standardised measures"
        case .reviewRules: "Set review and revision rules"
        case .generation: "Generate your protocol"
        }
    }

    /// Whether this stage uses agent-led guided discovery conversation.
    public var isGuidedDiscovery: Bool {
        switch self {
        case .recurrence, .maintaining, .targetBelief, .experimentDesign:
            true
        default:
            false
        }
    }

    /// Display number matching the roadmap (e.g. "7.5" for standardised measures).
    public var stageNumber: String {
        switch self {
        case .capture: "1"
        case .recurrence: "2"
        case .maintaining: "3"
        case .targetBelief: "4"
        case .interventionSelection: "5"
        case .experimentDesign: "6"
        case .captureFields: "7"
        case .standardisedMeasures: "7.5"
        case .reviewRules: "8"
        case .generation: "9"
        }
    }
}
