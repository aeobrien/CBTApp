import Foundation

/// A single execution instance of a protocol.
public struct Run: Codable, Sendable, Equatable, Identifiable {

    // MARK: - Identity

    public var id: UUID
    public var protocolID: UUID
    public var protocolVersion: String

    // MARK: - Timestamps

    public var timestampStart: Date
    public var timestampEnd: Date?

    // MARK: - Capture payload

    public var situation: String?
    public var hotThought: String?
    public var emotions: [EmotionRating]
    public var bodySignals: [BodySignal]
    public var urge: UrgeType?
    public var beliefStrengthBefore: Int?

    // MARK: - Guided discovery

    public var predictionResponse: String?
    public var alternativeResponse: String?

    // MARK: - Intervention

    public var chosenInterventions: [String]

    // MARK: - Outcome

    public var emotionsAfter: [EmotionRating]
    public var beliefStrengthAfter: Int?
    public var urgeAfter: UrgeType?
    public var outcomeTags: [OutcomeTag]
    public var learningNote: String?
    public var forwardPlan: String?
    public var helpfulnessRating: HelpfulnessRating?

    // MARK: - Metadata

    public var completionStatus: RunCompletionStatus
    public var note: String?

    public init(
        id: UUID = UUID(),
        protocolID: UUID,
        protocolVersion: String = "1.0.0",
        timestampStart: Date = Date(),
        timestampEnd: Date? = nil,
        situation: String? = nil,
        hotThought: String? = nil,
        emotions: [EmotionRating] = [],
        bodySignals: [BodySignal] = [],
        urge: UrgeType? = nil,
        beliefStrengthBefore: Int? = nil,
        predictionResponse: String? = nil,
        alternativeResponse: String? = nil,
        chosenInterventions: [String] = [],
        emotionsAfter: [EmotionRating] = [],
        beliefStrengthAfter: Int? = nil,
        urgeAfter: UrgeType? = nil,
        outcomeTags: [OutcomeTag] = [],
        learningNote: String? = nil,
        forwardPlan: String? = nil,
        helpfulnessRating: HelpfulnessRating? = nil,
        completionStatus: RunCompletionStatus = .abandoned,
        note: String? = nil
    ) {
        self.id = id
        self.protocolID = protocolID
        self.protocolVersion = protocolVersion
        self.timestampStart = timestampStart
        self.timestampEnd = timestampEnd
        self.situation = situation
        self.hotThought = hotThought
        self.emotions = emotions
        self.bodySignals = bodySignals
        self.urge = urge
        self.beliefStrengthBefore = beliefStrengthBefore
        self.predictionResponse = predictionResponse
        self.alternativeResponse = alternativeResponse
        self.chosenInterventions = chosenInterventions
        self.emotionsAfter = emotionsAfter
        self.beliefStrengthAfter = beliefStrengthAfter
        self.urgeAfter = urgeAfter
        self.outcomeTags = outcomeTags
        self.learningNote = learningNote
        self.forwardPlan = forwardPlan
        self.helpfulnessRating = helpfulnessRating
        self.completionStatus = completionStatus
        self.note = note
    }
}

// MARK: - Supporting types

/// An emotion with its intensity rating.
public struct EmotionRating: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var emotion: EmotionType
    /// Intensity from 0 to 100.
    public var intensity: Int

    public init(
        id: UUID = UUID(),
        emotion: EmotionType,
        intensity: Int
    ) {
        self.id = id
        self.emotion = emotion
        self.intensity = max(0, min(100, intensity))
    }
}

/// Thumbs up/down rating for run helpfulness.
public enum HelpfulnessRating: String, Codable, Sendable {
    case helpful
    case notHelpful = "not_helpful"
}

// MARK: - Computed properties

extension Run {
    /// Duration of the run in seconds, if completed.
    public var durationSeconds: TimeInterval? {
        guard let end = timestampEnd else { return nil }
        return end.timeIntervalSince(timestampStart)
    }

    /// The average emotion intensity before the intervention.
    public var averageEmotionBefore: Double? {
        guard !emotions.isEmpty else { return nil }
        return Double(emotions.map(\.intensity).reduce(0, +)) / Double(emotions.count)
    }

    /// The average emotion intensity after the intervention.
    public var averageEmotionAfter: Double? {
        guard !emotionsAfter.isEmpty else { return nil }
        return Double(emotionsAfter.map(\.intensity).reduce(0, +)) / Double(emotionsAfter.count)
    }

    /// The change in emotion intensity (negative = improvement).
    public var emotionChange: Double? {
        guard let before = averageEmotionBefore, let after = averageEmotionAfter else { return nil }
        return after - before
    }

    /// The change in belief strength (negative = improvement).
    public var beliefStrengthChange: Int? {
        guard let before = beliefStrengthBefore, let after = beliefStrengthAfter else { return nil }
        return after - before
    }
}
