import Foundation

/// Generates a human-readable summary of a completed Run.
public enum RunSummary {

    /// Generate a plain-text summary from a completed run.
    public static func generate(from run: Run, protocolName: String) -> String {
        var lines: [String] = []

        lines.append("Run Summary — \(protocolName)")
        lines.append("")

        // Duration
        if let duration = run.durationSeconds {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            if minutes > 0 {
                lines.append("Duration: \(minutes)m \(seconds)s")
            } else {
                lines.append("Duration: \(seconds)s")
            }
        }

        // Situation
        if let situation = run.situation, !situation.isEmpty {
            lines.append("Situation: \(situation)")
        }

        // Hot thought
        if let hotThought = run.hotThought, !hotThought.isEmpty {
            lines.append("Hot thought: \"\(hotThought)\"")
        }

        // Emotions before
        if !run.emotions.isEmpty {
            let emotionList = run.emotions.map { "\($0.emotion.displayName) (\($0.intensity))" }.joined(separator: ", ")
            lines.append("Emotions before: \(emotionList)")
        }

        // Belief strength before
        if let belief = run.beliefStrengthBefore {
            lines.append("Belief strength before: \(belief)%")
        }

        // Interventions
        if !run.chosenInterventions.isEmpty {
            lines.append("Interventions: \(run.chosenInterventions.joined(separator: ", "))")
        }

        // Emotions after
        if !run.emotionsAfter.isEmpty {
            let emotionList = run.emotionsAfter.map { "\($0.emotion.displayName) (\($0.intensity))" }.joined(separator: ", ")
            lines.append("Emotions after: \(emotionList)")
        }

        // Emotion change
        if let change = run.emotionChange {
            if change < 0 {
                lines.append("Emotion shift: \(Int(change)) (improved)")
            } else if change > 0 {
                lines.append("Emotion shift: +\(Int(change)) (worsened)")
            } else {
                lines.append("Emotion shift: no change")
            }
        }

        // Belief strength after
        if let belief = run.beliefStrengthAfter {
            lines.append("Belief strength after: \(belief)%")
        }

        // Belief change
        if let change = run.beliefStrengthChange {
            if change < 0 {
                lines.append("Belief shift: \(change)% (weakened)")
            } else if change > 0 {
                lines.append("Belief shift: +\(change)% (strengthened)")
            } else {
                lines.append("Belief shift: no change")
            }
        }

        // Outcome tags
        if !run.outcomeTags.isEmpty {
            let tags = run.outcomeTags.map(\.displayName).joined(separator: ", ")
            lines.append("Observations: \(tags)")
        }

        // Learning note
        if let note = run.learningNote, !note.isEmpty {
            lines.append("Learning: \(note)")
        }

        // Forward plan
        if let plan = run.forwardPlan, !plan.isEmpty {
            lines.append("Forward plan: \(plan)")
        }

        return lines.joined(separator: "\n")
    }
}
