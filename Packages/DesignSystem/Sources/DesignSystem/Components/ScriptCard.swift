import SwiftUI

/// Displays intervention script text in a calm, readable card.
///
/// Used to show the therapist-voice script during interventions.
/// Supports optional step numbering and a timer indicator.
public struct ScriptCard: View {
    let title: String
    let script: String
    let isTimed: Bool
    let durationMinutes: Int?

    public init(title: String, script: String, isTimed: Bool = false, durationMinutes: Int? = nil) {
        self.title = title
        self.script = script
        self.isTimed = isTimed
        self.durationMinutes = durationMinutes
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.sm) {
            HStack {
                Text(title)
                    .font(CBTTypography.cardTitle)
                Spacer()
                if isTimed, let mins = durationMinutes {
                    Label("\(mins)m", systemImage: "timer")
                        .font(CBTTypography.detail)
                        .foregroundStyle(.secondary)
                }
            }

            Text(script)
                .font(CBTTypography.script)
                .foregroundStyle(.secondary)
        }
        .padding(CBTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                .fill(CBTColors.accent.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                .strokeBorder(CBTColors.accent.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        ScriptCard(
            title: "Thought Defusion",
            script: "Notice the thought. Now try saying to yourself: 'I'm having the thought that...' followed by the thought. Notice how adding that prefix creates a small distance between you and the thought.",
            isTimed: true,
            durationMinutes: 3
        )
        ScriptCard(
            title: "Behavioural Experiment",
            script: "Before you begin, write down your prediction. What do you expect will happen? How strongly do you believe it (0-100%)?"
        )
    }
    .padding()
}
