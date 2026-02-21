import SwiftUI
import Features
import Utilities

@main
struct CBTApp: App {
    private let logger = CBTLogger.logger(for: .app)
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    init() {
        logger.info("App launched")
    }

    var body: some Scene {
        WindowGroup {
            if onboardingCompleted {
                ContentView()
            } else {
                OnboardingFlowCoordinator { [self] in
                    MainActor.assumeIsolated {
                        onboardingCompleted = true
                    }
                }
            }
        }
    }
}
