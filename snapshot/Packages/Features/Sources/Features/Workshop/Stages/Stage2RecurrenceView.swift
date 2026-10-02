import SwiftUI
import Domain
import DesignSystem

/// Stage 2: Guided discovery exploring when the pattern recurs.
struct Stage2RecurrenceView: View {
    @Bindable var viewModel: WorkshopFlowViewModel
    @State private var newTrigger: String = ""

    private var hasEnoughExchanges: Bool {
        viewModel.conversationMessages.filter({ $0.role == .user }).count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ConversationView(viewModel: viewModel)

            if hasEnoughExchanges {
                Divider()
                recurrenceCapture
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

    // MARK: - Recurrence capture

    private var recurrenceCapture: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Capture the key triggers and patterns from the conversation above.")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Trigger list
            VStack(alignment: .leading, spacing: 6) {
                Text("Triggers")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(viewModel.recurrenceTriggers, id: \.self) { trigger in
                    HStack {
                        Text(trigger)
                            .font(.subheadline)
                        Spacer()
                        Button {
                            viewModel.recurrenceTriggers.removeAll { $0 == trigger }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack {
                    TextField("Add a trigger...", text: $newTrigger)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)

                    Button {
                        let trimmed = newTrigger.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.recurrenceTriggers.append(trimmed)
                        newTrigger = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(CBTColors.accent)
                    }
                    .disabled(newTrigger.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            // Frequency
            VStack(alignment: .leading, spacing: 4) {
                Text("Frequency")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("e.g. Several times a week", text: $viewModel.recurrenceFrequency)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }

            // Timing pattern
            VStack(alignment: .leading, spacing: 4) {
                Text("Timing pattern")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("e.g. Mornings before work", text: $viewModel.recurrenceTimingPattern)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }
        }
        .padding()
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
