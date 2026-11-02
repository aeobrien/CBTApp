import Foundation

/// The screens of the first-launch onboarding sequence.
///
/// Four psychoeducation screens (~2 min total) followed by a
/// "ready" screen that leads into Workshop Mode.
public enum OnboardingScreen: String, CaseIterable, Hashable, Sendable {
    case welcome
    case hotThoughts
    case maintainingBehaviours
    case testing
    case ready
}
