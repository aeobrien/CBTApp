import SwiftUI
import Domain
import DesignSystem

/// Stage 2: Guided discovery exploring when the pattern recurs.
struct Stage2RecurrenceView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    private var hasEnoughExchanges: Bool {
        viewModel.conversationMessages.filter({ $0.role == .user }).count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ConversationView(viewModel: viewModel)

            if !viewModel.conversationMessages.isEmpty {
                FormulationView(formulation: viewModel.formulation)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("Recurrence")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .disabled(!hasEnoughExchanges)
            }
        }
        .task {
            await viewModel.requestOpeningMessage()
        }
    }
}

#Preview {
    NavigationStack {
        Stage2RecurrenceView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
