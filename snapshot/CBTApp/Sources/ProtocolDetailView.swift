import SwiftUI
import Domain
import DesignSystem
import Features
import Services
import Utilities

/// Production detail screen for a single protocol — dashboard, run, revise, measures, completion.
struct ProtocolDetailView: View {
    let cbtProtocol: CBTProtocol
    let dependencies: DependencyContainer
    var onStartRun: (() -> Void)?

    @State private var showingRunFlow = false
    @State private var showingWorkshopRevision = false
    @State private var showingMeasureAdmin: MeasureDefinition?
    @State private var showingCompletion: CompletionCandidate?

    @State private var dashboardVM: ProtocolDashboardViewModel?

    var body: some View {
        Group {
            if let dashboardVM {
                ProtocolDashboardView(
                    viewModel: dashboardVM,
                    onWeeklyReview: { /* handled via NavigationLink below */ },
                    onAdministerMeasure: { definition in
                        showingMeasureAdmin = definition
                    },
                    onComplete: { candidate in
                        showingCompletion = candidate
                    }
                )
            } else {
                ProgressView("Loading dashboard...")
            }
        }
        .navigationTitle(cbtProtocol.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showingRunFlow = true
                } label: {
                    Label("Run", systemImage: "play.circle.fill")
                }
                .accessibilityHint("Start a run with this protocol")

                Spacer()

                NavigationLink {
                    WeeklyReviewView(
                        viewModel: WeeklyReviewViewModel(
                            cbtProtocol: cbtProtocol,
                            runRepository: dependencies.runRepository,
                            measureRepository: dependencies.measureRepository
                        ),
                        onReviseProtocol: {
                            showingWorkshopRevision = true
                        }
                    )
                } label: {
                    Label("Weekly Review", systemImage: "chart.bar")
                }

                Spacer()

                Button {
                    showingWorkshopRevision = true
                } label: {
                    Label("Revise", systemImage: "pencil.circle")
                }
                .accessibilityHint("Open the workshop to revise this protocol")
            }
        }
        .task {
            let vm = ProtocolDashboardViewModel(
                cbtProtocol: cbtProtocol,
                runRepository: dependencies.runRepository,
                measureRepository: dependencies.measureRepository
            )
            dashboardVM = vm
            await vm.loadDashboard()
        }
        .fullScreenCover(isPresented: $showingRunFlow) {
            RunFlowCoordinator(
                protocolRepository: dependencies.protocolRepository,
                runRepository: dependencies.runRepository,
                safetySystem: dependencies.safetySystem,
                voiceInputService: dependencies.voiceInputService
            )
        }
        .fullScreenCover(isPresented: $showingWorkshopRevision) {
            WorkshopFlowCoordinator(
                agentService: dependencies.agentService,
                protocolRepository: dependencies.protocolRepository,
                safetySystem: dependencies.safetySystem,
                voiceInputService: dependencies.voiceInputService,
                existingProtocol: cbtProtocol
            )
        }
        .sheet(item: $showingMeasureAdmin) { definition in
            NavigationStack {
                MeasureAdminView(
                    viewModel: MeasureAdminViewModel(
                        definition: definition,
                        measureRepository: dependencies.measureRepository
                    ),
                    onDismiss: {
                        showingMeasureAdmin = nil
                        Task { await dashboardVM?.loadDashboard() }
                    }
                )
            }
        }
        .sheet(item: $showingCompletion) { candidate in
            NavigationStack {
                ProtocolCompletionView(
                    viewModel: ProtocolCompletionViewModel(
                        cbtProtocol: cbtProtocol,
                        candidate: candidate,
                        protocolRepository: dependencies.protocolRepository
                    ),
                    onDismiss: {
                        showingCompletion = nil
                    }
                )
            }
        }
        .onChange(of: showingRunFlow) { _, isShowing in
            if !isShowing { Task { await dashboardVM?.loadDashboard() } }
        }
        .onChange(of: showingWorkshopRevision) { _, isShowing in
            if !isShowing { Task { await dashboardVM?.loadDashboard() } }
        }
    }
}

#Preview {
    NavigationStack {
        let deps = DependencyContainer.makePreview()
        ProtocolDetailView(
            cbtProtocol: SampleData.lateNightRumination,
            dependencies: deps
        )
    }
}
