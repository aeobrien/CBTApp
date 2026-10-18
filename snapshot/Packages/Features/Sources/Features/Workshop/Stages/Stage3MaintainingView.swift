import SwiftUI
import Domain
import DesignSystem

/// Stage 3: Guided discovery exploring maintaining behaviours.
struct Stage3MaintainingView: View {
    @Bindable var viewModel: WorkshopFlowViewModel
    @State private var showBehaviourPicker = false

    private var hasEnoughExchanges: Bool {
        viewModel.conversationMessages.filter({ $0.role == .user }).count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ConversationView(viewModel: viewModel)

            if hasEnoughExchanges {
                Divider()
                behaviourConfirmation
            }
        }
        .navigationTitle("Maintaining")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .disabled(viewModel.identifiedBehaviours.isEmpty)
            }
        }
        .task {
            await viewModel.requestOpeningMessage()
        }
    }

    // MARK: - Behaviour confirmation

    private var behaviourConfirmation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Maintaining behaviours identified:")
                .font(.subheadline)
                .fontWeight(.medium)

            if viewModel.identifiedBehaviours.isEmpty {
                Text("Tap + to add behaviours from the conversation above.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.identifiedBehaviours) { behaviour in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(behaviour.type.displayName)
                                .font(.subheadline)
                            Spacer()
                            Button {
                                viewModel.identifiedBehaviours.removeAll { $0.id == behaviour.id }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if !behaviour.shortTermRelief.isEmpty {
                            Text("Relief: \(behaviour.shortTermRelief)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !behaviour.longTermCost.isEmpty {
                            Text("Cost: \(behaviour.longTermCost)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Button {
                showBehaviourPicker = true
            } label: {
                Label("Add Behaviour", systemImage: "plus.circle")
                    .font(.subheadline)
            }
        }
        .padding()
        .sheet(isPresented: $showBehaviourPicker) {
            BehaviourPickerSheet(identifiedBehaviours: $viewModel.identifiedBehaviours)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Behaviour Picker

private struct BehaviourPickerSheet: View {
    @Binding var identifiedBehaviours: [MaintainingBehaviour]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: MaintainingBehaviourType?
    @State private var shortTermRelief: String = ""
    @State private var longTermCost: String = ""

    var body: some View {
        NavigationStack {
            List {
                if let selected = selectedType {
                    Section("Details for \(selected.displayName)") {
                        TextField("Short-term relief (optional)", text: $shortTermRelief)
                        TextField("Long-term cost (optional)", text: $longTermCost)
                        Button("Add") {
                            identifiedBehaviours.append(MaintainingBehaviour(
                                type: selected,
                                shortTermRelief: shortTermRelief,
                                longTermCost: longTermCost
                            ))
                            selectedType = nil
                            shortTermRelief = ""
                            longTermCost = ""
                        }
                    }
                }

                Section("Behaviour types") {
                    ForEach(MaintainingBehaviourType.allCases) { behaviourType in
                        let isSelected = identifiedBehaviours.contains { $0.type == behaviourType }
                        Button {
                            if isSelected {
                                identifiedBehaviours.removeAll { $0.type == behaviourType }
                                if selectedType == behaviourType {
                                    selectedType = nil
                                }
                            } else {
                                selectedType = behaviourType
                                shortTermRelief = ""
                                longTermCost = ""
                            }
                        } label: {
                            HStack {
                                Text(behaviourType.displayName)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(CBTColors.accent)
                                } else if selectedType == behaviourType {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(CBTColors.accent)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Behaviour")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Stage3MaintainingView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
