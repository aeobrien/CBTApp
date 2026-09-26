import SwiftUI
import Domain
import DesignSystem

/// Stage 7.5: Select standardised measures (PHQ-9, GAD-7) and frequency.
struct Stage7_5MeasuresView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    var body: some View {
        List {
            Section {
                Text("Standardised measures help track progress over time. Select any you'd like to use.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(MeasureDefinition.allCases) { measure in
                let isSelected = viewModel.selectedMeasures.contains { $0.measureID == measure.id }
                let selectedIndex = viewModel.selectedMeasures.firstIndex { $0.measureID == measure.id }

                Section {
                    Toggle(isOn: Binding(
                        get: { isSelected },
                        set: { newValue in
                            if newValue {
                                viewModel.selectedMeasures.append(
                                    StandardisedMeasure(measureID: measure.id, frequency: .weekly)
                                )
                            } else {
                                viewModel.selectedMeasures.removeAll { $0.measureID == measure.id }
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(measure.id)
                                .font(.headline)
                            Text(measure.fullName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(CBTColors.accent)

                    if isSelected, let idx = selectedIndex {
                        Picker("Frequency", selection: Binding(
                            get: { viewModel.selectedMeasures[idx].frequency },
                            set: { viewModel.selectedMeasures[idx].frequency = $0 }
                        )) {
                            ForEach(MeasureFrequency.allCases) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Measures")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    Task { await viewModel.advance() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Stage7_5MeasuresView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
