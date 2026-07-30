import Foundation

/// In-memory mock implementation of MeasureRepositoryProtocol for testing and previews.
public actor MockMeasureRepository: MeasureRepositoryProtocol {
    public var scores: [String: [MeasureScore]]

    public init(scores: [String: [MeasureScore]] = [:]) {
        self.scores = scores
    }

    public func fetchScores(measureID: String) async throws -> [MeasureScore] {
        scores[measureID] ?? []
    }

    public func fetchScores(measureID: String, from startDate: Date, to endDate: Date) async throws -> [MeasureScore] {
        (scores[measureID] ?? []).filter { $0.date >= startDate && $0.date <= endDate }
    }

    public func saveScore(_ score: MeasureScore, measureID: String) async throws {
        scores[measureID, default: []].append(score)
    }

    public func latestScore(measureID: String) async throws -> MeasureScore? {
        scores[measureID]?.max(by: { $0.date < $1.date })
    }
}
