import Foundation

/// Types of interventions from the curated library.
public enum InterventionType: String, Codable, Sendable, CaseIterable, Identifiable {
    case behaviouralExperiment = "behavioural_experiment"
    case defusion
    case gradedExposureStep = "graded_exposure_step"
    case behaviouralActivation = "behavioural_activation"
    case delayExperiment = "delay_experiment"
    case oppositeAction = "opposite_action"
    case ruminationScheduling = "rumination_scheduling"
    case problemSolvingStep = "problem_solving_step"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .behaviouralExperiment: "Behavioural experiment"
        case .defusion: "Defusion"
        case .gradedExposureStep: "Graded exposure step"
        case .behaviouralActivation: "Behavioural activation"
        case .delayExperiment: "Delay experiment"
        case .oppositeAction: "Opposite action"
        case .ruminationScheduling: "Rumination scheduling"
        case .problemSolvingStep: "Problem-solving step"
        }
    }
}
