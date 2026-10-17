import Foundation

/// Broad emotional theme categories for the Quick Triage wizard.
public enum TriageTheme: String, Codable, Sendable, CaseIterable, Identifiable {
    case loss
    case comparison
    case fearOfFailure = "fear_of_failure"
    case perfectionism
    case socialThreat = "social_threat"
    case uncertainty

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .loss: "Loss"
        case .comparison: "Comparison"
        case .fearOfFailure: "Fear of failure"
        case .perfectionism: "Perfectionism"
        case .socialThreat: "Social threat"
        case .uncertainty: "Uncertainty"
        }
    }
}
