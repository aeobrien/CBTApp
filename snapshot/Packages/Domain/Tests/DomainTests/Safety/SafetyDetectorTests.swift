import XCTest
@testable import Domain

final class DisengagementDetectorTests: XCTestCase {

    private let protocolID = UUID()

    private func makeRun(
        daysAgo: Double,
        status: RunCompletionStatus = .completed
    ) -> Run {
        let start = Date().addingTimeInterval(-daysAgo * 86400)
        return Run(
            protocolID: protocolID,
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(180),
            completionStatus: status
        )
    }

    func testNoRunsReturnsNil() {
        let result = DisengagementDetector.evaluate(runs: [])
        XCTAssertNil(result)
    }

    func testRecentRunReturnsNil() {
        let runs = [makeRun(daysAgo: 5)]
        let result = DisengagementDetector.evaluate(runs: runs)
        XCTAssertNil(result)
    }

    func testExactly14DaysReturnsAlert() {
        let now = Date()
        let run = Run(
            protocolID: protocolID,
            timestampStart: Calendar.current.date(byAdding: .day, value: -14, to: now)!,
            timestampEnd: Calendar.current.date(byAdding: .day, value: -14, to: now)!.addingTimeInterval(180),
            completionStatus: .completed
        )
        let result = DisengagementDetector.evaluate(runs: [run], relativeTo: now)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.kind, .disengagement)
        XCTAssertTrue(result?.canContinue ?? false)
    }

    func test13DaysReturnsNil() {
        let now = Date()
        let run = Run(
            protocolID: protocolID,
            timestampStart: Calendar.current.date(byAdding: .day, value: -13, to: now)!,
            timestampEnd: Calendar.current.date(byAdding: .day, value: -13, to: now)!.addingTimeInterval(180),
            completionStatus: .completed
        )
        let result = DisengagementDetector.evaluate(runs: [run], relativeTo: now)
        XCTAssertNil(result)
    }

    func testOnlyAbandonedRunsReturnsNil() {
        let runs = [makeRun(daysAgo: 20, status: .abandoned)]
        let result = DisengagementDetector.evaluate(runs: runs)
        XCTAssertNil(result)
    }

    func testMixedAbandonedRecentAndCompletedOld() {
        let runs = [
            makeRun(daysAgo: 2, status: .abandoned),
            makeRun(daysAgo: 20, status: .completed)
        ]
        let result = DisengagementDetector.evaluate(runs: runs)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.kind, .disengagement)
    }
}

final class CompulsiveUseDetectorTests: XCTestCase {

    private let protocolID = UUID()

    private func makeRun(
        hoursAgo: Double,
        emotionBefore: Int = 60,
        emotionAfter: Int = 30
    ) -> Run {
        let start = Date().addingTimeInterval(-hoursAgo * 3600)
        return Run(
            protocolID: protocolID,
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(180),
            emotions: [EmotionRating(emotion: .anxiety, intensity: emotionBefore)],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: emotionAfter)],
            completionStatus: .completed
        )
    }

    func testFewRunsInDayReturnsNil() {
        let runs = (0..<3).map { makeRun(hoursAgo: Double($0)) }
        let result = CompulsiveUseDetector.evaluate(runs: runs)
        XCTAssertNil(result)
    }

    func testSevenRunsIn24HoursReturnsAlert() {
        let runs = (0..<7).map { makeRun(hoursAgo: Double($0) * 3) }
        let result = CompulsiveUseDetector.evaluate(runs: runs)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.kind, .compulsiveUse)
        XCTAssertTrue(result?.canContinue ?? false)
    }

    func testEightRunsOver48HoursReturnsNil() {
        // 8 runs spread across 48 hours — no more than 5 in any 24h window
        let runs = (0..<8).map { makeRun(hoursAgo: Double($0) * 7) }
        let result = CompulsiveUseDetector.evaluate(runs: runs)
        XCTAssertNil(result)
    }

    func testEightConsecutiveNonImprovingReturnsAlert() {
        // emotionAfter >= emotionBefore → emotionChange >= 0
        // Spread over many days to avoid frequency trigger
        let runs = (0..<8).map { i in
            makeRun(hoursAgo: Double(i) * 48 + 100, emotionBefore: 50, emotionAfter: 60)
        }
        let result = CompulsiveUseDetector.evaluate(runs: runs)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.kind, .compulsiveUse)
    }

    func testMixedImprovementReturnsNil() {
        // Spread runs over many days to avoid frequency trigger
        var runs = (0..<8).map { i in
            makeRun(hoursAgo: Double(i) * 48 + 100, emotionBefore: 50, emotionAfter: 60)
        }
        // Make one run improving — breaks the non-improvement streak
        runs[4] = makeRun(hoursAgo: 4 * 48 + 100, emotionBefore: 60, emotionAfter: 30)
        let result = CompulsiveUseDetector.evaluate(runs: runs)
        XCTAssertNil(result)
    }

    func testRunsWithoutEmotionDataSkipped() {
        // Runs with no emotions → emotionChange is nil → allSatisfy returns false
        // Spread over many days to avoid frequency trigger
        let runs = (0..<8).map { i in
            Run(
                protocolID: protocolID,
                timestampStart: Date().addingTimeInterval(-Double(i) * 48 * 3600 - 100 * 3600),
                completionStatus: .completed
            )
        }
        let result = CompulsiveUseDetector.evaluate(runs: runs)
        XCTAssertNil(result)
    }
}
