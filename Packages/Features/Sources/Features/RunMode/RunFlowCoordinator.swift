import SwiftUI
import Domain
import DesignSystem

/// Coordinates the Run Mode flow using NavigationStack.
public struct RunFlowCoordinator: View {
    @State private var viewModel: RunFlowViewModel
    @Environment(\.dismiss) private var dismiss

    public init(
        protocolRepository: any ProtocolRepositoryProtocol,
        runRepository: any RunRepositoryProtocol,
        safetySystem: (any SafetySystemProtocol)? = nil,
        voiceInputService: (any VoiceInputServiceProtocol)? = nil
    ) {
        _viewModel = State(initialValue: RunFlowViewModel(
            protocolRepository: protocolRepository,
            runRepository: runRepository,
            safetySystem: safetySystem,
            voiceInputService: voiceInputService
        ))
    }

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ProtocolSelectionView(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .navigationDestination(for: RunFlowStep.self) { step in
                    switch step {
                    case .protocolSelection:
                        ProtocolSelectionView(viewModel: viewModel)
                    case .capture:
                        CaptureView(viewModel: viewModel)
                    case .guidedDiscovery:
                        GuidedDiscoveryView(viewModel: viewModel)
                    case .intervention:
                        InterventionView(viewModel: viewModel)
                    case .outcome:
                        OutcomeView(viewModel: viewModel)
                    case .summary:
                        SummaryView(viewModel: viewModel) {
                            dismiss()
                        }
                    }
                }
        }
        .safetyCover(alert: Binding(
            get: { viewModel.pendingSafetyAlert },
            set: { viewModel.pendingSafetyAlert = $0 }
        ))
    }
}

#Preview {
    RunFlowCoordinator(
        protocolRepository: MockProtocolRepository(protocols: SampleData.allProtocols),
        runRepository: MockRunRepository()
    )
}
