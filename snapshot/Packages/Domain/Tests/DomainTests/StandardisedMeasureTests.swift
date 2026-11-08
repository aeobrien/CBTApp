import Testing
import Foundation
@testable import Domain

@Suite("StandardisedMeasure")
struct StandardisedMeasureTests {

    @Test("isDue returns true when never administered")
    func neverAdministered() {
        let measure = StandardisedMeasure(measureID: "PHQ-9", frequency: .weekly)
        #expect(measure.isDue() == true)
    }

    @Test("isDue returns false when recently administered")
    func recentlyAdministered() {
        let measure = StandardisedMeasure(
            measureID: "PHQ-9",
            frequency: .weekly,
            lastAdministered: Date()
        )
        #expect(measure.isDue() == false)
    }

    @Test("isDue returns true when interval has elapsed")
    func intervalElapsed() {
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        let measure = StandardisedMeasure(
            measureID: "PHQ-9",
            frequency: .weekly,
            lastAdministered: eightDaysAgo
        )
        #expect(measure.isDue() == true)
    }

    @Test("isDue respects fortnightly frequency")
    func fortnightlyNotYetDue() {
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let measure = StandardisedMeasure(
            measureID: "GAD-7",
            frequency: .fortnightly,
            lastAdministered: tenDaysAgo
        )
        #expect(measure.isDue() == false)
    }

    @Test("latestScore returns most recent")
    func latestScore() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let recentDate = Date()
        let measure = StandardisedMeasure(
            measureID: "PHQ-9",
            frequency: .weekly,
            scores: [
                MeasureScore(date: oldDate, totalScore: 15),
                MeasureScore(date: recentDate, totalScore: 10)
            ]
        )
        #expect(measure.latestScore?.totalScore == 10)
    }

    @Test("latestScore returns nil when no scores")
    func noScores() {
        let measure = StandardisedMeasure(measureID: "PHQ-9", frequency: .weekly)
        #expect(measure.latestScore == nil)
    }

    @Test("MeasureScore JSON round-trip")
    func scoreRoundTrip() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let score = MeasureScore(totalScore: 12, itemResponses: [1, 2, 1, 0, 2, 3, 1, 1, 1])
        let data = try encoder.encode(score)
        let decoded = try decoder.decode(MeasureScore.self, from: data)
        #expect(decoded.totalScore == 12)
        #expect(decoded.itemResponses?.count == 9)
    }
}
