import SwiftUI
import Domain
import DesignSystem

/// Coordinates the Workshop flow using NavigationStack.
///
/// Pass `existingProtocol` for revision mode (pre-fills state from the protocol).
/// Pass `nil` for new protocol creation.
public struct WorkshopFlowCoordinator: View {
    @State private var viewModel: WorkshopFlowViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingExitConfirmation = false

    public init(
        agentService: any AgentServiceProtocol,
        protocolRepository: any ProtocolRepositoryProtocol,
        safetySystem: (any SafetySystemProtocol)? = nil,
        voiceInputService: (any VoiceInputServiceProtocol)? = nil,
        existingProtocol: CBTProtocol? = nil
    ) {
        _viewModel = State(initialValue: WorkshopFlowViewModel(
            agentService: agentService,
            protocolRepository: protocolRepository,
            safetySystem: safetySystem,
            voiceInputService: voiceInputService,
            existingProtocol: existingProtocol
        ))
    }

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            Stage1CaptureView(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingExitConfirmation = true
                        }
                    }
                }
                .navigationDestination(for: WorkshopStage.self) { stage in
                    switch stage {
                    case .capture:
                        Stage1CaptureView(viewModel: viewModel)
                    case .recurrence:
                        Stage2RecurrenceView(viewModel: viewModel)
                    case .maintaining:
                        Stage3MaintainingView(viewModel: viewModel)
                    case .targetBelief:
                        Stage4TargetBeliefView(viewModel: viewModel)
                    case .interventionSelection:
                        Stage5InterventionView(viewModel: viewModel)
                    case .experimentDesign:
                        Stage6ExperimentView(viewModel: viewModel)
                    case .captureFields:
                        Stage7CaptureFieldsView(viewModel: viewModel)
                    case .standardisedMeasures:
                        Stage7_5MeasuresView(viewModel: viewModel)
                    case .reviewRules:
                        Stage8ReviewRulesView(viewModel: viewModel)
                    case .generation:
                        Stage9GenerationView(viewModel: viewModel, onComplete: { dismiss() })
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    StageProgressBar(current: viewModel.currentStage)
                        .padding(.vertical, 8)
                        .background(.bar)
                }
        }
        .safetyCover(alert: Binding(
            get: { viewModel.pendingSafetyAlert },
            set: { viewModel.pendingSafetyAlert = $0 }
        ))
        .onAppear {
            viewModel.loadExistingProtocol()
        }
        .confirmationDialog(
            "Leave Workshop?",
            isPresented: $showingExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Leave", role: .destructive) {
                dismiss()
            }
            Button("Continue Workshop", role: .cancel) {}
        } message: {
            Text("Your progress will be lost.")
        }
    }
}

#Preview {
    WorkshopFlowCoordinator(
        agentService: MockAgentService(),
        protocolRepository: MockProtocolRepository()
    )
}
