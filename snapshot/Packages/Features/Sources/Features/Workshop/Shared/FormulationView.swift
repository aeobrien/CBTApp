import SwiftUI
import Domain
import DesignSystem

/// Progressive visualisation of the CBT formulation being built.
///
/// Shows the trigger → appraisal → emotion → behaviour chain,
/// with maintaining cycles displayed as feedback loops. Sections
/// that haven't been filled yet appear greyed out.
struct FormulationView: View {
    let formulation: Formulation

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Formulation")
                .font(.headline)

            if formulation.triggerAppraisalLinks.isEmpty {
                placeholderCard("Complete Stage 1 to see the formulation")
            } else {
                ForEach(formulation.triggerAppraisalLinks) { link in
                    chainView(link: link)
                }
            }

            if !formulation.maintainingCycles.isEmpty {
                Divider()
                Text("Maintaining Cycles")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(formulation.maintainingCycles) { cycle in
                    cycleCard(cycle: cycle)
                }
            }
        }
        .padding()
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Chain view

    @ViewBuilder
    private func chainView(link: TriggerAppraisalLink) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            nodeRow(label: "Trigger", value: link.trigger, icon: "bolt.fill", filled: true)

            connectionArrow()

            if link.appraisal.isEmpty {
                nodeRow(label: "Belief", value: "To be identified...", icon: "brain.head.profile", filled: false)
            } else {
                nodeRow(label: "Belief", value: link.appraisal, icon: "brain.head.profile", filled: true)
            }

            connectionArrow()

            nodeRow(label: "Emotion", value: link.emotion.displayName, icon: "heart.fill", filled: true)

            connectionArrow()

            nodeRow(label: "Urge", value: link.behaviour.displayName, icon: "arrow.right.circle.fill", filled: true)
        }
    }

    private func nodeRow(label: String, value: String, icon: String, filled: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(filled ? CBTColors.accent : .gray)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(filled ? .primary : .tertiary)
            }
        }
    }

    private func connectionArrow() -> some View {
        HStack {
            Spacer().frame(width: 10)
            Image(systemName: "arrow.down")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Cycle card

    private func cycleCard(cycle: MaintainingCycle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(CBTColors.warning)
                Text(cycle.behaviour.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            if !cycle.shortTermFunction.isEmpty {
                Text("Short-term: \(cycle.shortTermFunction)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !cycle.longTermCost.isEmpty {
                Text("Long-term cost: \(cycle.longTermCost)")
                    .font(.caption)
                    .foregroundStyle(CBTColors.negative)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func placeholderCard(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    FormulationView(formulation: Formulation(
        triggerAppraisalLinks: [
            TriggerAppraisalLink(
                trigger: "Presenting at work",
                appraisal: "I'll mess up and everyone will judge me",
                emotion: .anxiety,
                behaviour: .avoid
            )
        ],
        maintainingCycles: [
            MaintainingCycle(
                behaviour: .avoidance,
                shortTermFunction: "Temporary relief from anxiety",
                longTermCost: "Never learn I can handle it"
            )
        ]
    ))
    .padding()
}
