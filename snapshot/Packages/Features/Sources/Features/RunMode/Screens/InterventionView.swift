import SwiftUI
import Domain
import DesignSystem

/// Screen D: Execute the recommended intervention.
struct InterventionView: View {
    @Bindable var viewModel: RunFlowViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CBTSpacing.lg) {
                if let intervention = viewModel.currentIntervention {
                    // Script card
                    ScriptCard(
                        title: intervention.title,
                        script: intervention.script,
                        isTimed: intervention.isTimed,
                        durationMinutes: intervention.durationEstimate / 60
                    )

                    // Timer if timed
                    if let timer = viewModel.timerModel {
                        CBTTimerView(model: timer)
                    }

                    // Steps checklist
                    if !intervention.steps.isEmpty {
                        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                            Text("Steps")
                                .font(CBTTypography.bodySecondary)
                            CBTChecklist(
                                items: intervention.steps,
                                checkedIndices: $viewModel.checkedSteps
                            )
                        }
                    }

                    // Type badge
                    HStack {
                        Text(intervention.type.displayName)
                            .font(CBTTypography.detail)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    // Switch intervention button
                    Button("Try a different intervention") {
                        viewModel.switchIntervention()
                    }
                    .font(CBTTypography.bodySecondary)
                    .foregroundStyle(CBTColors.accent)
                } else {
                    ContentUnavailableView(
                        "No intervention available",
                        systemImage: "lightbulb.slash",
                        description: Text("The engine could not recommend an intervention for this run.")
                    )
                }
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Do")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InterventionView(viewModel: .preview())
    }
}
