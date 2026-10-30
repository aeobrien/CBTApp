import SwiftUI
import SwiftData
import Domain
import Data
import Features
import Services
import Utilities
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

@main
struct CBTApp: App {
    private let logger = CBTLogger.logger(for: .app)
    private let dependencies: DependencyContainer

    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @AppStorage("appearanceOverride") private var appearanceOverride = "system"
    @State private var showPostOnboardingWorkshop = false
    @State private var isUnlocked = false
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let deps = DependencyContainer()
        self.dependencies = deps
        logger.info("App launched")
    }

    private var resolvedColorScheme: ColorScheme? {
        switch appearanceOverride {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingCompleted {
                    OnboardingFlowCoordinator {
                        MainActor.assumeIsolated {
                            onboardingCompleted = true
                            showPostOnboardingWorkshop = true
                        }
                    }
                } else {
                    homeView
                }
            }
            .overlay {
                if appLockEnabled && !isUnlocked {
                    lockScreen
                }
            }
            .preferredColorScheme(resolvedColorScheme)
            .modelContainer(dependencies.modelContainer)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active && appLockEnabled && !isUnlocked {
                    authenticate()
                }
            }
            .onAppear {
                if !appLockEnabled { isUnlocked = true }
            }
        }
    }

    @ViewBuilder
    private var homeView: some View {
        HomeView(
            viewModel: HomeViewModel(
                protocolRepository: dependencies.protocolRepository,
                runRepository: dependencies.runRepository
            ),
            dependencies: dependencies
        )
        .task {
            await dependencies.seedSampleDataIfNeeded()
        }
        .task {
            await dependencies.prepareVoiceModel()
        }
        .fullScreenCover(isPresented: $showPostOnboardingWorkshop) {
            WorkshopFlowCoordinator(
                agentService: dependencies.agentService,
                protocolRepository: dependencies.protocolRepository,
                safetySystem: dependencies.safetySystem,
                voiceInputService: dependencies.voiceInputService
            )
        }
    }

    // MARK: - App Lock

    @ViewBuilder
    private var lockScreen: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("CBT is Locked")
                    .font(.title2.bold())
                Button("Unlock") { authenticate() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func authenticate() {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            logger.warning("Authentication not available: \(error?.localizedDescription ?? "unknown")")
            isUnlocked = true
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock CBT") { success, authError in
            DispatchQueue.main.async {
                if success {
                    isUnlocked = true
                    logger.info("App unlocked via biometric/passcode")
                } else {
                    logger.debug("Authentication failed: \(authError?.localizedDescription ?? "cancelled")")
                }
            }
        }
        #else
        isUnlocked = true
        #endif
    }
}
