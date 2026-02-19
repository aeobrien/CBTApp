import SwiftUI
import Domain
import Utilities

struct ContentView: View {
    private let logger = CBTLogger.logger(for: .app)

    var body: some View {
        NavigationStack {
            List {
                Section("Sample Protocols") {
                    ForEach(SampleData.allProtocols) { proto in
                        NavigationLink {
                            ProtocolDetailTestView(cbtProtocol: proto)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(proto.name)
                                    .font(.headline)
                                Text(proto.summary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                Section("Logging") {
                    Button("Test Logging") {
                        let correlationID = String(UUID().uuidString.prefix(8).lowercased())
                        logger.debug("Debug: flow trace test", correlationID: correlationID)
                        logger.info("Info: state change test", correlationID: correlationID)
                        logger.warning("Warning: recoverable issue test", correlationID: correlationID)
                        logger.error("Error: failure test", correlationID: correlationID)
                    }
                }
            }
            .navigationTitle("CBT App")
        }
        .onAppear {
            logger.info("ContentView appeared — \(SampleData.allProtocols.count) sample protocols loaded")
        }
    }
}

/// Test view showing protocol details for Phase 1 manual testing.
struct ProtocolDetailTestView: View {
    let cbtProtocol: CBTProtocol

    var body: some View {
        List {
            Section("Basic Info") {
                LabeledContent("Name", value: cbtProtocol.name)
                LabeledContent("Version", value: cbtProtocol.version)
                LabeledContent("Status", value: cbtProtocol.status.displayName)
            }

            Section("Triggers (\(cbtProtocol.whenToUse.count))") {
                ForEach(cbtProtocol.whenToUse, id: \.self) { trigger in
                    Text(trigger)
                        .font(.subheadline)
                }
            }

            Section("Hot Thoughts (\(cbtProtocol.hotThoughtTemplates.count))") {
                ForEach(cbtProtocol.hotThoughtTemplates, id: \.self) { thought in
                    Text(thought)
                        .font(.subheadline)
                        .italic()
                }
            }

            Section("Target") {
                LabeledContent("Belief", value: cbtProtocol.targets.targetBelief)
                if let loop = cbtProtocol.targets.targetLoop {
                    LabeledContent("Loop", value: loop.displayName)
                }
            }

            Section("Maintaining Behaviours (\(cbtProtocol.maintainingBehaviours.count))") {
                ForEach(cbtProtocol.maintainingBehaviours) { behaviour in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(behaviour.type.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if !behaviour.shortTermRelief.isEmpty {
                            Text("Relief: \(behaviour.shortTermRelief)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !behaviour.longTermCost.isEmpty {
                            Text("Cost: \(behaviour.longTermCost)")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                }
            }

            Section("Interventions (\(cbtProtocol.interventions.count))") {
                ForEach(cbtProtocol.interventions) { intervention in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intervention.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(intervention.script)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text(intervention.type.displayName)
                            Spacer()
                            Text("\(intervention.durationEstimate / 60)m")
                            if intervention.isTimed {
                                Image(systemName: "timer")
                            }
                        }
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 2)
                }
            }

            Section("Experiments (\(cbtProtocol.experiments.count))") {
                ForEach(cbtProtocol.experiments) { experiment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prediction: \(experiment.prediction)")
                            .font(.subheadline)
                        Text("Steps: \(experiment.steps.joined(separator: " → "))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Success: \(experiment.successCriteria)")
                            .font(.caption)
                            .foregroundStyle(.green.opacity(0.8))
                    }
                }
            }

            Section("Safety") {
                Text(cbtProtocol.safety.message)
                    .font(.subheadline)
                ForEach(cbtProtocol.safety.resources) { resource in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(resource.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(resource.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(cbtProtocol.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
