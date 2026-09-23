import SwiftUI
import Domain
import DesignSystem

/// Stage 5: Select evidence-based interventions from the library.
struct Stage5InterventionView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose interventions that fit your pattern. Select at least one.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ForEach(viewModel.availableInterventions) { template in
                    interventionCard(template: template)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Interventions")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .disabled(viewModel.selectedInterventions.isEmpty)
            }
        }
    }

    @ViewBuilder
    private func interventionCard(template: InterventionTemplate) -> some View {
        let isSelected = viewModel.selectedInterventions.contains { $0.id == template.id }

        Button {
            if isSelected {
                viewModel.deselectIntervention(template)
            } else {
                viewModel.selectIntervention(template)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.headline)
                        Text(template.type.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? CBTColors.accent : .secondary)
                        .font(.title2)
                }

                Text(template.indication)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                if let script = template.exampleScripts.first {
                    Text(script)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                        .italic()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? CBTColors.accent.opacity(0.08) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? CBTColors.accent : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        Stage5InterventionView(viewModel: {
            let vm = WorkshopFlowViewModel(
                agentService: MockAgentService(),
                protocolRepository: MockProtocolRepository()
            )
            return vm
        }())
    }
}
