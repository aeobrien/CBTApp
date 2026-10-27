import SwiftUI
import Domain
import DesignSystem

/// Stage 4: Guided discovery to articulate the target belief.
struct Stage4TargetBeliefView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    private var hasEnoughExchanges: Bool {
        viewModel.conversationMessages.filter({ $0.role == .user }).count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ConversationView(viewModel: viewModel)

            if hasEnoughExchanges {
                Divider()
                beliefConfirmation
            }
        }
        .navigationTitle("Target Belief")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .disabled(viewModel.confirmedTargetBelief.isEmpty)
            }
        }
        .task {
            await viewModel.requestOpeningMessage()
        }
    }

    private var beliefConfirmation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target belief:")
                .font(.subheadline)
                .fontWeight(.medium)

            TextField("e.g. I'm not good enough", text: $viewModel.confirmedTargetBelief, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
                .voiceInput(text: $viewModel.confirmedTargetBelief, voiceService: viewModel.voiceInputService)

            Text("Edit the belief above until it captures the core pattern.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        Stage4TargetBeliefView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
