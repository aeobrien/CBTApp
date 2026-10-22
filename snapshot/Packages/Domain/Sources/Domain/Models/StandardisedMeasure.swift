import Foundation

/// A standardised clinical measure tracked over time (e.g., PHQ-9, GAD-7).
public struct StandardisedMeasure: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var measureID: String
    public var frequency: MeasureFrequency
    public var lastAdministered: Date?
    public var scores: [MeasureScore]

    public init(
        id: UUID = UUID(),
        measureID: String,
        frequency: MeasureFrequency,
        lastAdministered: Date? = nil,
        scores: [MeasureScore] = []
    ) {
        self.id = id
        self.measureID = measureID
        self.frequency = frequency
        self.lastAdministered = lastAdministered
        self.scores = scores
    }

    /// Whether it's time to administer this measure again.
    public func isDue(relativeTo now: Date = Date()) -> Bool {
        guard let lastAdministered else { return true }
        let calendar = Calendar.current
        let daysSinceLast = calendar.dateComponents([.day], from: lastAdministered, to: now).day ?? 0
        return daysSinceLast >= frequency.intervalDays
    }

    /// The most recent score, if any.
    public var latestScore: MeasureScore? {
        scores.max(by: { $0.date < $1.date })
    }
}

/// A single timestamped score for a standardised measure.
public struct MeasureScore: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var date: Date
    public var totalScore: Int
    public var itemResponses: [Int]?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalScore: Int,
        itemResponses: [Int]? = nil
    ) {
        self.id = id
        self.date = date
        self.totalScore = totalScore
        self.itemResponses = itemResponses
    }
}
