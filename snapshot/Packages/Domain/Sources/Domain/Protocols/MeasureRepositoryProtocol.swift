import Foundation

/// Repository for standardised measure scores.
public protocol MeasureRepositoryProtocol: Sendable {
    /// Fetch all scores for a given measure type.
    func fetchScores(measureID: String) async throws -> [MeasureScore]

    /// Fetch scores within a date range.
    func fetchScores(measureID: String, from startDate: Date, to endDate: Date) async throws -> [MeasureScore]

    /// Save a new score.
    func saveScore(_ score: MeasureScore, measureID: String) async throws

    /// Fetch the most recent score for a measure.
    func latestScore(measureID: String) async throws -> MeasureScore?
}
