import Foundation
import SwiftData
import Domain

/// SwiftData model for persisting individual MeasureScore entries.
@Model
public final class PersistedMeasureScore {
    public var scoreID: UUID
    public var measureID: String
    public var date: Date
    public var totalScore: Int
    public var itemResponsesData: Data?

    public init(from score: MeasureScore, measureID: String) throws {
        self.scoreID = score.id
        self.measureID = measureID
        self.date = score.date
        self.totalScore = score.totalScore
        if let items = score.itemResponses {
            self.itemResponsesData = try JSONEncoder().encode(items)
        }
    }

    public func toDomain() throws -> MeasureScore {
        var itemResponses: [Int]?
        if let data = itemResponsesData {
            itemResponses = try JSONDecoder().decode([Int].self, from: data)
        }
        return MeasureScore(
            id: scoreID,
            date: date,
            totalScore: totalScore,
            itemResponses: itemResponses
        )
    }
}
