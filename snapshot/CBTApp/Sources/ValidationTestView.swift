import SwiftUI
import Domain
import Services

/// Test harness for Phase 6 validation pipeline.
/// Shows validation results for sample protocols and intentionally invalid protocols.
struct ValidationTestView: View {
    var body: some View {
        List {
            Section("Sample Protocols") {
                ForEach(SampleData.allProtocols) { proto in
                    ValidationRow(protocol: proto)
                }
            }

            Section("Invalid: Empty Name") {
                let proto = CBTProtocol(name: "", summary: "Has a summary",
                    targets: ProtocolTargets(targetBelief: "A belief"),
                    interventions: [makeValidIntervention()])
                ValidationRow(protocol: proto)
            }

            Section("Invalid: No Interventions") {
                let proto = CBTProtocol(name: "No interventions", summary: "Missing interventions",
                    targets: ProtocolTargets(targetBelief: "A belief"),
                    interventions: [])
                ValidationRow(protocol: proto)
            }

            Section("Invalid: Script Too Long") {
                let longScript = String(repeating: "a", count: 300)
                let intervention = InterventionInstance(
                    interventionID: "be-prediction-test",
                    type: .behaviouralExperiment,
                    title: "Too long",
                    script: longScript,
                    durationEstimate: 60
                )
                let proto = CBTProtocol(name: "Long script", summary: "Script exceeds limit",
                    targets: ProtocolTargets(targetBelief: "A belief"),
                    interventions: [intervention])
                ValidationRow(protocol: proto)
            }

            Section("Invalid: Content Policy") {
                let intervention = InterventionInstance(
                    interventionID: "be-prediction-test",
                    type: .behaviouralExperiment,
                    title: "Medical",
                    script: "Please prescribe 20mg of medication",
                    durationEstimate: 60
                )
                let proto = CBTProtocol(name: "Policy violation", summary: "Contains medical language",
                    targets: ProtocolTargets(targetBelief: "A belief"),
                    interventions: [intervention])
                ValidationRow(protocol: proto)
            }
        }
        .navigationTitle("Validation Pipeline")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func makeValidIntervention() -> InterventionInstance {
        InterventionInstance(
            interventionID: "be-prediction-test",
            type: .behaviouralExperiment,
            title: "Prediction Test",
            script: "Test your prediction.",
            durationEstimate: 600
        )
    }
}

/// Displays validation result for a single protocol.
private struct ValidationRow: View {
    let `protocol`: CBTProtocol

    var body: some View {
        let result = ValidationPipeline.validate(`protocol`)
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(result.isValid ? .green : .red)
                Text(`protocol`.name.isEmpty ? "(empty name)" : `protocol`.name)
                    .font(.headline)
            }

            if result.isValid {
                Text("All checks passed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(result.errors.count) error(s)")
                    .font(.caption)
                    .foregroundStyle(.red)
                ForEach(Array(result.errors.enumerated()), id: \.offset) { _, error in
                    HStack(alignment: .top, spacing: 4) {
                        Text(error.fieldPath)
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .frame(minWidth: 80, alignment: .leading)
                        Text(error.message)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ValidationTestView()
    }
}
