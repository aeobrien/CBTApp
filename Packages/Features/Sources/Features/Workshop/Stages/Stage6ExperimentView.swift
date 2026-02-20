import SwiftUI
import Domain
import DesignSystem

/// Stage 6: Guided discovery to design a behavioural experiment.
struct Stage6ExperimentView: View {
    @Bindable var viewModel: WorkshopFlowViewModel
    @State private var showStructuredFields = false

    private var hasEnoughExchanges: Bool {
        viewModel.conversationMessages.filter({ $0.role == .user }).count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            if showStructuredFields {
                structuredExperiment
            } else {
                ConversationView(viewModel: viewModel)

                if hasEnoughExchanges {
                    Divider()
                    Button {
                        showStructuredFields = true
                    } label: {
                        Label("Structure the experiment", systemImage: "list.bullet.rectangle")
                            .font(.subheadline)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Experiment")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                if showStructuredFields {
                    Button("Back to Chat") {
                        showStructuredFields = false
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(showStructuredFields)
        .task {
            await viewModel.requestOpeningMessage()
        }
    }

    private var structuredExperiment: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prediction")
                        .font(.headline)
                    Text("What does the belief predict will happen?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g. If I speak up, everyone will judge me", text: $viewModel.experimentPrediction, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps")
                        .font(.headline)
                    ForEach(viewModel.experimentSteps.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            TextField("Step", text: $viewModel.experimentSteps[index])
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    Button {
                        viewModel.experimentSteps.append("")
                    } label: {
                        Label("Add Step", systemImage: "plus.circle")
                            .font(.subheadline)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Success Criteria")
                        .font(.headline)
                    Text("What would count as the prediction being wrong?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g. At least one person responds positively", text: $viewModel.experimentSuccessCriteria, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        Stage6ExperimentView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
