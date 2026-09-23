import SwiftUI
import Domain
import DesignSystem

/// Stage 8: Configure review and revision rules.
struct Stage8ReviewRulesView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    var body: some View {
        List {
            Section {
                Text("Review rules trigger check-ins and adjustments based on your usage patterns.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Active Rules") {
                ForEach(viewModel.reviewRules) { rule in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "gearshape.2")
                                .foregroundStyle(CBTColors.accent)
                                .font(.caption)
                            Text(rule.condition.displayLabel)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        Text(rule.action.displayLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indices in
                    viewModel.reviewRules.remove(atOffsets: indices)
                }
            }

            Section {
                Button {
                    viewModel.reviewRules = ReviewRule.defaults
                } label: {
                    Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Review Rules")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
            }
        }
    }
}

// MARK: - Rule display helpers

private extension String {
    var displayLabel: String {
        switch self {
        case "after_5_runs": "After 5 runs"
        case "no_shift_after_3_runs": "No shift after 3 runs"
        case "prompt_review": "Prompt a review"
        case "revise_scripts_experiment": "Suggest revising scripts and experiment"
        default: self.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

#Preview {
    NavigationStack {
        Stage8ReviewRulesView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
