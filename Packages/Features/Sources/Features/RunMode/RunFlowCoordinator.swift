import SwiftUI
import Domain
import DesignSystem

/// Coordinates the Run Mode flow using NavigationStack.
public struct RunFlowCoordinator: View {
    @State private var viewModel: RunFlowViewModel
    @Environment(\.dismiss) private var dismiss

    public init(
        protocolRepository: any ProtocolRepositoryProtocol,
        runRepository: any RunRepositoryProtocol
    ) {
        _viewModel = State(initialValue: RunFlowViewModel(
            protocolRepository: protocolRepository,
            runRepository: runRepository
        ))
    }

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ProtocolSelectionView(viewModel: viewModel)
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
    }
}

#Preview {
    RunFlowCoordinator(
        protocolRepository: MockProtocolRepository(protocols: SampleData.allProtocols),
        runRepository: MockRunRepository()
    )
}
