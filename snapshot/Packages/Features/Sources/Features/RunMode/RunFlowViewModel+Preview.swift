import Domain
import Utilities

/// Preview helper for RunFlowViewModel.
extension RunFlowViewModel {
    @MainActor
    static func preview() -> RunFlowViewModel {
        RunFlowViewModel(
            protocolRepository: MockProtocolRepository(protocols: SampleData.allProtocols),
            runRepository: MockRunRepository()
        )
    }
}
