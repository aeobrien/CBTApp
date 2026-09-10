import XCTest
@testable import Domain

final class WeeklyReviewGeneratorTests: XCTestCase {

    private let protocolID = UUID()

    private var sampleProtocol: CBTProtocol {
        SampleData.lateNightRumination
    }

    private func makeRun(
        emotionBefore: Int = 60,
        emotionAfter: Int = 40,
        beliefBefore: Int = 70,
        beliefAfter: Int = 50,
        tags: [OutcomeTag] = [.intensityDropped],
        daysAgo: Double = 0
    ) -> Run {
        let start = Date().addingTimeInterval(-daysAgo * 86400)
        return Run(
            protocolID: sampleProtocol.id,
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(180),
            emotions: [EmotionRating(emotion: .anxiety, intensity: emotionBefore)],
            beliefStrengthBefore: beliefBefore,
            chosenInterventions: ["delay_01"],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: emotionAfter)],
            beliefStrengthAfter: beliefAfter,
            outcomeTags: tags,
            helpfulnessRating: .helpful,
            completionStatus: .completed
        )
    }

    func testZeroRunsReturnsEmpty() {
        let insights = WeeklyReviewGenerator.generate(runs: [], cbtProtocol: sampleProtocol)
        XCTAssertTrue(insights.isEmpty)
    }

    func testConsistencyStreakWith3Runs() {
        let runs = (0..<3).map { makeRun(daysAgo: Double($0)) }
        let insights = WeeklyReviewGenerator.generate(runs: runs, cbtProtocol: sampleProtocol)
        XCTAssertTrue(insights.contains { $0.type == .consistencyStreak })
    }

    func testRevisionSuggestionWhenMostlyGotWorse() {
        let runs = (0..<5).map { _ in makeRun(tags: [.gotWorse]) }
        let insights = WeeklyReviewGenerator.generate(runs: runs, cbtProtocol: sampleProtocol)
        XCTAssertTrue(insights.contains { $0.type == .revisionSuggestion })
    }

    func testEmotionTrendInsight() {
        // This week: emotion change -20 (60->40)
        let thisWeekRuns = (0..<3).map { makeRun(emotionBefore: 60, emotionAfter: 40, daysAgo: Double($0)) }
        // Last week: emotion change -10 (60->50)
        let lastWeekRuns = (0..<3).map { makeRun(emotionBefore: 60, emotionAfter: 50, daysAgo: Double(8 + $0)) }

        let allRuns = thisWeekRuns + lastWeekRuns
        let insights = WeeklyReviewGenerator.generate(runs: allRuns, cbtProtocol: sampleProtocol)
        XCTAssertTrue(insights.contains { $0.type == .emotionTrend })
    }

    func testBeliefShiftWith3DecliningRuns() {
        // Runs ordered most recent first (as repo returns them)
        let runs = [
            makeRun(beliefAfter: 30, daysAgo: 0),
            makeRun(beliefAfter: 40, daysAgo: 1),
            makeRun(beliefAfter: 50, daysAgo: 2)
        ]
        let insights = WeeklyReviewGenerator.generate(runs: runs, cbtProtocol: sampleProtocol)
        XCTAssertTrue(insights.contains { $0.type == .beliefShift })
    }

    func testMeasureChangeInsight() {
        let scores: [String: [MeasureScore]] = [
            "GAD-7": [
                MeasureScore(date: Date().addingTimeInterval(-86400 * 14), totalScore: 15),
                MeasureScore(date: Date(), totalScore: 10)
            ]
        ]
        let runs = [makeRun()]
        let insights = WeeklyReviewGenerator.generate(runs: runs, cbtProtocol: sampleProtocol, measureScores: scores)
        XCTAssertTrue(insights.contains { $0.type == .measureChange })
    }

    func testMaxFiveInsights() {
        // Create conditions for many insights
        let thisWeekRuns = (0..<5).map { makeRun(
            emotionBefore: 60,
            emotionAfter: 40,
            beliefAfter: 30,
            tags: [.intensityDropped, .predictionDidntHappen, .canHandleMoreThanThought],
            daysAgo: Double($0)
        )}
        let lastWeekRuns = (0..<3).map { makeRun(emotionBefore: 60, emotionAfter: 50, daysAgo: Double(8 + $0)) }

        let scores: [String: [MeasureScore]] = [
            "GAD-7": [
                MeasureScore(date: Date().addingTimeInterval(-86400 * 14), totalScore: 15),
                MeasureScore(date: Date(), totalScore: 8)
            ]
        ]

        let insights = WeeklyReviewGenerator.generate(
            runs: thisWeekRuns + lastWeekRuns,
            cbtProtocol: sampleProtocol,
            measureScores: scores
        )
        XCTAssertLessThanOrEqual(insights.count, 5)
    }

    func testInsightsSortedByPriority() {
        let thisWeekRuns = (0..<5).map { makeRun(
            emotionBefore: 60, emotionAfter: 40,
            beliefAfter: 30,
            tags: [.predictionDidntHappen],
            daysAgo: Double($0)
        )}
        let lastWeekRuns = (0..<3).map { makeRun(emotionBefore: 60, emotionAfter: 50, daysAgo: Double(8 + $0)) }

        let insights = WeeklyReviewGenerator.generate(
            runs: thisWeekRuns + lastWeekRuns,
            cbtProtocol: sampleProtocol
        )
        // Verify sorted by priority ascending
        for i in 0..<(insights.count - 1) {
            XCTAssertLessThanOrEqual(insights[i].priority, insights[i + 1].priority)
        }
    }
}
