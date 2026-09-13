import SwiftUI
import Domain
import Features

/// Test harness for Phase 8: Evidence & Review.
/// Tabs for Dashboard, Measures, and Completion.
struct EvidenceTestView: View {
    @State private var selectedTab = 0
    @State private var selectedMeasure: MeasureDefinition?
    @State private var showCompletion = false

    private let sampleProtocol = SampleData.lateNightRumination
    private let mockRunRepo: MockRunRepository
    private let mockMeasureRepo: MockMeasureRepository

    init() {
        // Use completion-ready sample runs (low belief strength, improving emotions)
        let runs = SampleData.completionReadyRuns(
            forProtocolID: SampleData.lateNightRumination.id
        )
        mockRunRepo = MockRunRepository(runs: runs)
        mockMeasureRepo = MockMeasureRepository(scores: [
            "GAD-7": [
                MeasureScore(
                    date: Date().addingTimeInterval(-86400 * 14),
                    totalScore: 14
                ),
                MeasureScore(
                    date: Date().addingTimeInterval(-86400 * 1),
                    totalScore: 9
                )
            ]
        ])
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard tab
            NavigationStack {
                ProtocolDashboardView(
                    viewModel: ProtocolDashboardViewModel(
                        cbtProtocol: sampleProtocol,
                        runRepository: mockRunRepo,
                        measureRepository: mockMeasureRepo
                    ),
                    onWeeklyReview: { selectedTab = 1 },
                    onAdministerMeasure: { def in
                        selectedMeasure = def
                    },
                    onComplete: { _ in showCompletion = true }
                )
            }
            .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            .tag(0)

            // Weekly Review tab
            NavigationStack {
                WeeklyReviewView(
                    viewModel: WeeklyReviewViewModel(
                        cbtProtocol: sampleProtocol,
                        runRepository: mockRunRepo,
                        measureRepository: mockMeasureRepo
                    )
                )
            }
            .tabItem { Label("Review", systemImage: "lightbulb") }
            .tag(1)

            // Measures tab
            NavigationStack {
                List {
                    ForEach(MeasureDefinition.allCases, id: \.rawValue) { def in
                        Button(def.fullName) {
                            selectedMeasure = def
                        }
                    }
                }
                .navigationTitle("Measures")
            }
            .tabItem { Label("Measures", systemImage: "list.clipboard") }
            .tag(2)
        }
        .sheet(item: $selectedMeasure) { def in
            NavigationStack {
                MeasureAdminView(
                    viewModel: MeasureAdminViewModel(
                        definition: def,
                        measureRepository: mockMeasureRepo
                    ),
                    onDismiss: { selectedMeasure = nil }
                )
            }
        }
        .sheet(isPresented: $showCompletion) {
            NavigationStack {
                ProtocolCompletionView(
                    viewModel: ProtocolCompletionViewModel(
                        cbtProtocol: sampleProtocol,
                        candidate: CompletionCandidate(
                            isCandidate: true,
                            reason: "Sustained improvement across 7 runs.",
                            suggestedKeyTrigger: sampleProtocol.whenToUse.first,
                            suggestedUpdatedBelief: sampleProtocol.targets.targetBelief,
                            suggestedBestInterventionID: "delay_01",
                            suggestedBestInterventionTitle: "10-minute delay"
                        ),
                        protocolRepository: MockProtocolRepository(protocols: [sampleProtocol])
                    ),
                    onDismiss: { showCompletion = false }
                )
            }
        }
    }
}

#Preview {
    EvidenceTestView()
}
