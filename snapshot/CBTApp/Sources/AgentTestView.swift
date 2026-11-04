import SwiftUI
import Domain
import Services
import Utilities

/// Test harness for the Phase 7 Agent Service.
/// Enter an API key, generate a protocol via the live OpenAI API, and view the result.
struct AgentTestView: View {
    private let logger = CBTLogger.logger(for: .agentService)

    @State private var apiKey = ""
    @State private var userMessage = "I have anxiety about making mistakes at work. I ruminate after meetings and avoid speaking up."
    @State private var isLoading = false
    @State private var resultText = ""
    @State private var generatedProtocol: CBTProtocol?

    var body: some View {
        List {
            Section("API Key") {
                SecureField("OpenAI API Key", text: $apiKey)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Section("Workshop Message") {
                TextEditor(text: $userMessage)
                    .frame(minHeight: 80)
            }

            Section {
                Button {
                    Task { await generateProtocol() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Generate Protocol")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(apiKey.isEmpty || isLoading)
            }

            if let proto = generatedProtocol {
                Section("Generated Protocol") {
                    LabeledContent("Name", value: proto.name)
                    LabeledContent("Version", value: proto.version)
                    LabeledContent("Status", value: proto.status.displayName)
                    NavigationLink("View Full Details") {
                        ProtocolDetailTestView(cbtProtocol: proto)
                    }
                }

                Section("Summary") {
                    Text(proto.summary)
                        .font(.subheadline)
                }

                Section("When to Use (\(proto.whenToUse.count))") {
                    ForEach(proto.whenToUse, id: \.self) { trigger in
                        Text(trigger)
                            .font(.subheadline)
                    }
                }

                Section("Interventions (\(proto.interventions.count))") {
                    ForEach(proto.interventions) { intervention in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(intervention.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(intervention.type.displayName)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(intervention.script)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("ID: \(intervention.interventionID)")
                                Spacer()
                                Text("\(intervention.durationEstimate / 60)m")
                                Text("(\(intervention.script.count)/240 chars)")
                            }
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("Experiments (\(proto.experiments.count))") {
                    ForEach(proto.experiments) { experiment in
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
                    Text(proto.safety.message)
                        .font(.subheadline)
                    ForEach(proto.safety.resources) { resource in
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

                Section("Validation Checks") {
                    let allScriptsValid = proto.interventions.allSatisfy { $0.script.count <= 240 }
                    let allTriggersValid = proto.whenToUse.allSatisfy { $0.count <= 80 }
                    let validIDs = Set(InterventionLibrary.allTemplates.map(\.id))
                    let allIDsValid = proto.interventions.allSatisfy { validIDs.contains($0.interventionID) }

                    Label("Scripts ≤ 240 chars", systemImage: allScriptsValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(allScriptsValid ? .green : .red)
                    Label("Triggers ≤ 80 chars", systemImage: allTriggersValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(allTriggersValid ? .green : .red)
                    Label("All intervention IDs valid", systemImage: allIDsValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(allIDsValid ? .green : .red)
                    Label("Safety info present", systemImage: !proto.safety.message.isEmpty ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(!proto.safety.message.isEmpty ? .green : .red)
                    Label("Has experiments", systemImage: !proto.experiments.isEmpty ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(!proto.experiments.isEmpty ? .green : .red)
                }
            }

            if !resultText.isEmpty {
                Section("Error") {
                    Text(resultText)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("Agent Test")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func generateProtocol() async {
        isLoading = true
        resultText = ""
        generatedProtocol = nil

        let client = OpenAIAPIClient(apiKeyOverride: apiKey)
        let service = OpenAIAgentService(apiClient: client)

        let context = GenerationContext(
            workshopMessages: [
                ConversationMessage(role: .user, content: userMessage)
            ]
        )

        do {
            let result = try await service.generateProtocol(context: context)
            switch result {
            case .success(let proto):
                generatedProtocol = proto
                logger.info("Protocol generated: \(proto.name)")

            case .repairFailed(let errors):
                resultText = "REPAIR FAILED (\(errors.count) error(s)):\n\n\(errors.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n\n"))"
                logger.error("Generation repair failed: \(errors.count) errors")

            case .networkError(let message):
                resultText = "NETWORK ERROR\n\(message)"
                logger.error("Generation network error: \(message)")
            }
        } catch {
            resultText = "ERROR\n\(error.localizedDescription)"
            logger.error("Generation threw: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        AgentTestView()
    }
}
