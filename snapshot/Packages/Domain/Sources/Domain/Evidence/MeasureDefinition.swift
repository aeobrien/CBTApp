import Foundation

/// Severity level for standardised measure scoring bands.
public enum Severity: String, Sendable, Equatable {
    case minimal
    case mild
    case moderate
    case moderatelySevere = "moderately_severe"
    case severe
}

/// A scoring band mapping a score range to a severity label.
public struct ScoringBand: Sendable, Equatable {
    public var range: ClosedRange<Int>
    public var label: String
    public var severity: Severity

    public init(range: ClosedRange<Int>, label: String, severity: Severity) {
        self.range = range
        self.label = label
        self.severity = severity
    }
}

/// Definitions for standardised clinical measures (PHQ-9, GAD-7).
public enum MeasureDefinition: String, CaseIterable, Sendable, Identifiable {
    case phq9 = "PHQ-9"
    case gad7 = "GAD-7"

    public var id: String { rawValue }

    public var fullName: String {
        switch self {
        case .phq9: "Patient Health Questionnaire-9"
        case .gad7: "Generalised Anxiety Disorder-7"
        }
    }

    public var items: [String] {
        switch self {
        case .phq9:
            [
                "Little interest or pleasure in doing things",
                "Feeling down, depressed, or hopeless",
                "Trouble falling or staying asleep, or sleeping too much",
                "Feeling tired or having little energy",
                "Poor appetite or overeating",
                "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
                "Trouble concentrating on things, such as reading the newspaper or watching television",
                "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
                "Thoughts that you would be better off dead or of hurting yourself in some way"
            ]
        case .gad7:
            [
                "Feeling nervous, anxious, or on edge",
                "Not being able to stop or control worrying",
                "Worrying too much about different things",
                "Trouble relaxing",
                "Being so restless that it's hard to sit still",
                "Becoming easily annoyed or irritable",
                "Feeling afraid as if something awful might happen"
            ]
        }
    }

    public var maxScore: Int {
        switch self {
        case .phq9: 27
        case .gad7: 21
        }
    }

    public var responseOptions: [String] {
        ["Not at all", "Several days", "More than half the days", "Nearly every day"]
    }

    public var scoringBands: [ScoringBand] {
        switch self {
        case .phq9:
            [
                ScoringBand(range: 0...4, label: "Minimal", severity: .minimal),
                ScoringBand(range: 5...9, label: "Mild", severity: .mild),
                ScoringBand(range: 10...14, label: "Moderate", severity: .moderate),
                ScoringBand(range: 15...19, label: "Moderately severe", severity: .moderatelySevere),
                ScoringBand(range: 20...27, label: "Severe", severity: .severe)
            ]
        case .gad7:
            [
                ScoringBand(range: 0...4, label: "Minimal", severity: .minimal),
                ScoringBand(range: 5...9, label: "Mild", severity: .mild),
                ScoringBand(range: 10...14, label: "Moderate", severity: .moderate),
                ScoringBand(range: 15...21, label: "Severe", severity: .severe)
            ]
        }
    }

    /// Look up the scoring band for a given total score.
    public func band(for score: Int) -> ScoringBand? {
        scoringBands.first { $0.range.contains(score) }
    }

    /// Resolve a measure ID string to a definition.
    public static func from(measureID: String) -> MeasureDefinition? {
        MeasureDefinition(rawValue: measureID)
    }
}
