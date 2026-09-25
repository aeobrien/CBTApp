import SwiftUI
import Domain

/// A scrollable reference view showing every DesignSystem component
/// in every state. Used for development QA and as a living style guide.
public struct ComponentCatalogueView: View {
    @State private var sliderValue: Double = 50
    @State private var beliefValue: Double = 65
    @State private var emotionSelection: Set<String> = Set(["Anxiety", "Shame"])
    @State private var outcomeSelection: Set<OutcomeTag> = Set([.uncomfortableButTolerable])
    @State private var checkedItems: Set<Int> = Set([0, 2])
    @State private var isRecording = false
    @State private var timerModel = TimerModel(targetDuration: 180)
    @State private var countupModel = TimerModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                sliderSection
                beliefSliderSection
                chipSection
                outcomeSection
                protocolCardSection
                scriptCardSection
                checklistSection
                timerSection
                voiceInputSection
                safetySection
            }
            .navigationTitle("Component Catalogue")
        }
    }

    // MARK: - Sections

    private var sliderSection: some View {
        Section("CBTSlider") {
            CBTSlider(label: "Anxiety Intensity", value: $sliderValue)
            CBTSlider(label: "No Value Display", value: .constant(30), showValue: false)
        }
    }

    private var beliefSliderSection: some View {
        Section("BeliefStrengthSlider") {
            BeliefStrengthSlider(value: $beliefValue)
        }
    }

    private var chipSection: some View {
        Section("SelectableChip + ChipGrid") {
            HStack {
                SelectableChip(label: "Selected", isSelected: true) {}
                SelectableChip(label: "Unselected", isSelected: false) {}
            }

            Text("Multi-select grid:")
                .font(CBTTypography.caption)
            ChipGrid(
                items: ["Anxiety", "Sadness", "Anger", "Frustration", "Shame", "Guilt", "Fear"],
                labelForItem: { $0 },
                selection: $emotionSelection
            )
        }
    }

    private var outcomeSection: some View {
        Section("OutcomeTagSelector") {
            OutcomeTagSelector(selection: $outcomeSelection)
        }
    }

    private var protocolCardSection: some View {
        Section("ProtocolCard") {
            ProtocolCard(
                name: "Late-Night Rumination",
                summary: "For when you're lying in bed replaying conversations.",
                statusLabel: "Active",
                lastUsed: "2 days ago"
            )
            ProtocolCard(
                name: "Work Perfectionism",
                summary: "Targeting the belief that work must be flawless.",
                statusLabel: "Paused"
            )
        }
    }

    private var scriptCardSection: some View {
        Section("ScriptCard") {
            ScriptCard(
                title: "Thought Defusion",
                script: "Notice the thought. Now try saying: 'I'm having the thought that...' Notice how adding that prefix creates distance.",
                isTimed: true,
                durationMinutes: 3
            )
            ScriptCard(
                title: "Behavioural Experiment",
                script: "Write down your prediction before you begin."
            )
        }
    }

    private var checklistSection: some View {
        Section("CBTChecklist") {
            CBTChecklist(
                items: [
                    "Notice the thought",
                    "Label it as a thought",
                    "Let it pass without engaging",
                    "Return attention to breath"
                ],
                checkedIndices: $checkedItems
            )
        }
    }

    private var timerSection: some View {
        Section("CBTTimer") {
            VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                Text("Countdown (3 min)")
                    .font(CBTTypography.caption)
                CBTTimerView(model: timerModel)
            }

            VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                Text("Count-up (stopwatch)")
                    .font(CBTTypography.caption)
                CBTTimerView(model: countupModel)
            }
        }
    }

    private var voiceInputSection: some View {
        Section("VoiceInputButton") {
            HStack(spacing: CBTSpacing.xl) {
                VStack {
                    VoiceInputButton(isRecording: false) {
                        isRecording.toggle()
                    }
                    Text("Idle")
                        .font(CBTTypography.detail)
                }
                VStack {
                    VoiceInputButton(isRecording: true) {}
                    Text("Recording")
                        .font(CBTTypography.detail)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var safetySection: some View {
        Section("SafetyBanner") {
            SafetyBanner(
                message: "If you're in crisis, please reach out to one of these services.",
                resources: [
                    (name: "Samaritans", detail: "116 123"),
                    (name: "Crisis Text Line", detail: "Text SHOUT to 85258")
                ]
            )
        }
    }
}

#Preview {
    ComponentCatalogueView()
}
