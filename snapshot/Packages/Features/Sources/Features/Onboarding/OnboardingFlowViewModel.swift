import Foundation
import Domain
import Utilities

/// Drives the onboarding flow across 5 screens.
///
/// Lightweight ViewModel with no service dependencies — just
/// navigation state and an `onComplete` callback.
@Observable
@MainActor
public final class OnboardingFlowViewModel {

    // MARK: - Navigation

    public var navigationPath: [OnboardingScreen] = []

    public var currentScreen: OnboardingScreen {
        navigationPath.last ?? .welcome
    }

    // MARK: - Completion

    private nonisolated(unsafe) var onComplete: () -> Void
    private let logger: ModuleLogger

    // MARK: - Init

    public nonisolated init(
        onComplete: @escaping @Sendable () -> Void,
        logger: ModuleLogger = CBTLogger.logger(for: .app)
    ) {
        self.onComplete = onComplete
        self.logger = logger
    }

    // MARK: - Actions

    /// Advance to the next screen in sequence.
    public func advance() {
        let allScreens = OnboardingScreen.allCases
        guard let currentIndex = allScreens.firstIndex(of: currentScreen),
              currentIndex + 1 < allScreens.count else {
            return
        }
        let next = allScreens[currentIndex + 1]
        logger.debug("Onboarding advancing to: \(next.rawValue)")
        navigationPath.append(next)
    }

    /// Go back to the previous screen.
    public func goBack() {
        guard !navigationPath.isEmpty else { return }
        logger.debug("Onboarding going back from: \(currentScreen.rawValue)")
        navigationPath.removeLast()
    }

    /// Complete onboarding (user tapped "Start Workshop" on ready screen).
    public func finish() {
        logger.info("Onboarding finished")
        onComplete()
    }

    /// Skip onboarding entirely.
    public func skip() {
        logger.info("Onboarding skipped")
        onComplete()
    }
}
