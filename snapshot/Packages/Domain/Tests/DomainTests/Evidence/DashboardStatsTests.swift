import XCTest
@testable import Domain

final class DashboardStatsTests: XCTestCase {

    private let protocolID = UUID()

    private func makeRun(
        emotionBefore: Int? = 60,
        emotionAfter: Int? = 40,
        beliefBefore: Int? = 70,
        beliefAfter: Int? = 50,
        interventions: [String] = ["delay_01"],
        tags: [OutcomeTag] = [.intensityDropped],
        helpful: HelpfulnessRating? = .helpful,
        daysAgo: Double = 0,
        duration: TimeInterval? = 180
    ) -> Run {
        let start = Date().addingTimeInterval(-daysAgo * 86400)
        return Run(
            protocolID: protocolID,
            timestampStart: start,
            timestampEnd: duration.map { start.addingTimeInterval($0) },
            emotions: emotionBefore.map { [EmotionRating(emotion: .anxiety, intensity: $0)] } ?? [],
            beliefStrengthBefore: beliefBefore,
            chosenInterventions: interventions,
            emotionsAfter: emotionAfter.map { [EmotionRating(emotion: .anxiety, intensity: $0)] } ?? [],
            beliefStrengthAfter: beliefAfter,
            outcomeTags: tags,
            helpfulnessRating: helpful,
            completionStatus: .completed
        )
    }

    func testStatsFromZeroRuns() {
        let stats = DashboardStatsCalculator.calculate(from: [])
        XCTAssertEqual(stats.completedRunCount, 0)
        XCTAssertNil(stats.averageEmotionChange)
        XCTAssertTrue(stats.beliefStrengthTrend.isEmpty)
        XCTAssertTrue(stats.outcomeTagCounts.isEmpty)
        XCTAssertNil(stats.helpfulnessRate)
        XCTAssertNil(stats.mostUsedInterventionID)
        XCTAssertNil(stats.averageDurationSeconds)
    }

    func testStatsFromOneRun() {
        let run = makeRun()
        let stats = DashboardStatsCalculator.calculate(from: [run])
        XCTAssertEqual(stats.completedRunCount, 1)
        XCTAssertNotNil(stats.averageEmotionChange)
        XCTAssertEqual(stats.averageEmotionChange!, -20.0, accuracy: 0.1)
    }

    func testStatsFromFiveRuns() {
        let runs = (0..<5).map { i in
            makeRun(emotionBefore: 60, emotionAfter: 40 - i * 2, daysAgo: Double(i))
        }
        let stats = DashboardStatsCalculator.calculate(from: runs)
        XCTAssertEqual(stats.completedRunCount, 5)
        XCTAssertNotNil(stats.averageEmotionChange)
        // avg after: (40+38+36+34+32)/5 = 36, avg change = 36-60 = -24
        XCTAssertEqual(stats.averageEmotionChange!, -24.0, accuracy: 0.1)
    }

    func testOutcomeTagCounting() {
        let runs = [
            makeRun(tags: [.intensityDropped, .predictionDidntHappen]),
            makeRun(tags: [.intensityDropped]),
            makeRun(tags: [.gotWorse])
        ]
        let stats = DashboardStatsCalculator.calculate(from: runs)
        XCTAssertEqual(stats.outcomeTagCounts[.intensityDropped], 2)
        XCTAssertEqual(stats.outcomeTagCounts[.predictionDidntHappen], 1)
        XCTAssertEqual(stats.outcomeTagCounts[.gotWorse], 1)
    }

    func testMostUsedInterventionID() {
        let runs = [
            makeRun(interventions: ["delay_01"]),
            makeRun(interventions: ["delay_01"]),
            makeRun(interventions: ["defusion_01"])
        ]
        let stats = DashboardStatsCalculator.calculate(from: runs)
        XCTAssertEqual(stats.mostUsedInterventionID, "delay_01")
    }

    func testHelpfulnessRate() {
        let runs = [
            makeRun(helpful: .helpful),
            makeRun(helpful: .helpful),
            makeRun(helpful: .notHelpful),
            makeRun(helpful: nil)
        ]
        let stats = DashboardStatsCalculator.calculate(from: runs)
        // 2 helpful out of 3 rated = 66.7%
        XCTAssertNotNil(stats.helpfulnessRate)
        XCTAssertEqual(stats.helpfulnessRate!, 2.0 / 3.0, accuracy: 0.01)
    }

    func testAverageDuration() {
        let runs = [
            makeRun(duration: 120),
            makeRun(duration: 180),
            makeRun(duration: 240)
        ]
        let stats = DashboardStatsCalculator.calculate(from: runs)
        XCTAssertEqual(stats.averageDurationSeconds!, 180.0, accuracy: 0.1)
    }

    func testBeliefStrengthTrendChronological() {
        let runs = [
            makeRun(beliefBefore: 80, beliefAfter: 60, daysAgo: 3),
            makeRun(beliefBefore: 70, beliefAfter: 50, daysAgo: 1),
            makeRun(beliefBefore: 75, beliefAfter: 55, daysAgo: 2)
        ]
        let stats = DashboardStatsCalculator.calculate(from: runs)
        XCTAssertEqual(stats.beliefStrengthTrend.count, 3)
        // Should be sorted chronologically (oldest first)
        XCTAssertEqual(stats.beliefStrengthTrend[0].before, 80)
        XCTAssertEqual(stats.beliefStrengthTrend[1].before, 75)
        XCTAssertEqual(stats.beliefStrengthTrend[2].before, 70)
    }

    func testRunsWithMissingEmotionDataExcluded() {
        let runs = [
            makeRun(emotionBefore: nil, emotionAfter: nil),
            makeRun(emotionBefore: 60, emotionAfter: 40)
        ]
        let stats = DashboardStatsCalculator.calculate(from: runs)
        // Only one run has valid emotion change
        XCTAssertEqual(stats.averageEmotionChange!, -20.0, accuracy: 0.1)
    }

    func testAbandonedRunsExcluded() {
        var abandoned = makeRun()
        abandoned.completionStatus = .abandoned
        let completed = makeRun()
        let stats = DashboardStatsCalculator.calculate(from: [abandoned, completed])
        XCTAssertEqual(stats.completedRunCount, 1)
    }
}
