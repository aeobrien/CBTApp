import SwiftUI
import Domain

/// Coordinates the onboarding flow using NavigationStack.
///
/// Presents 5 screens: welcome, hot thoughts, maintaining behaviours,
/// testing beliefs, and ready. Calls `onComplete` when the user finishes
/// or skips.
public struct OnboardingFlowCoordinator: View {
    @State private var viewModel: OnboardingFlowViewModel

    public init(onComplete: @escaping @Sendable () -> Void) {
        _viewModel = State(initialValue: OnboardingFlowViewModel(onComplete: onComplete))
    }

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            OnboardingWelcomeView(viewModel: viewModel)
                .navigationDestination(for: OnboardingScreen.self) { screen in
                    switch screen {
                    case .welcome:
                        OnboardingWelcomeView(viewModel: viewModel)
                    case .hotThoughts:
                        OnboardingHotThoughtsView(viewModel: viewModel)
                    case .maintainingBehaviours:
                        OnboardingBehavioursView(viewModel: viewModel)
                    case .testing:
                        OnboardingTestingView(viewModel: viewModel)
                    case .ready:
                        OnboardingReadyView(viewModel: viewModel)
                    }
                }
        }
    }
}

#Preview {
    OnboardingFlowCoordinator(onComplete: {})
}
