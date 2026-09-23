import SwiftUI
import Domain
import DesignSystem

/// Stage 7: Configure which fields to capture during runs.
struct Stage7CaptureFieldsView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    var body: some View {
        List {
            Section {
                Text("Choose what to capture each time you run the protocol.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Capture Fields") {
                ForEach(CaptureFieldType.allCases) { fieldType in
                    let isEnabled = viewModel.captureFields.contains { $0.fieldType == fieldType }

                    Toggle(isOn: Binding(
                        get: { isEnabled },
                        set: { newValue in
                            if newValue {
                                viewModel.captureFields.append(
                                    CaptureField(fieldType: fieldType, label: fieldType.defaultLabel)
                                )
                            } else {
                                viewModel.captureFields.removeAll { $0.fieldType == fieldType }
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(fieldType.defaultLabel)
                                .font(.subheadline)
                            Text(fieldType.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(CBTColors.accent)
                }
            }
        }
        .navigationTitle("Capture Fields")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
            }
        }
    }
}

// MARK: - CaptureFieldType helpers

extension CaptureFieldType {
    var defaultLabel: String {
        switch self {
        case .situationText: "Situation"
        case .hotThoughtPicker: "Hot Thought"
        case .emotionPicker: "Emotion"
        case .bodySignalPicker: "Body Signals"
        case .urgePicker: "Urge"
        case .slider: "Custom Slider"
        case .beliefStrength: "Belief Strength"
        }
    }

    var description: String {
        switch self {
        case .situationText: "What's happening right now"
        case .hotThoughtPicker: "The most distressing thought"
        case .emotionPicker: "Rate the emotion you're feeling"
        case .bodySignalPicker: "Physical sensations"
        case .urgePicker: "What you feel like doing"
        case .slider: "A custom 0-100 rating"
        case .beliefStrength: "How strongly you believe the hot thought"
        }
    }
}

#Preview {
    NavigationStack {
        Stage7CaptureFieldsView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
