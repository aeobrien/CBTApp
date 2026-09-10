import XCTest
@testable import Features
@testable import Domain

@MainActor
final class ProtocolDashboardViewModelTests: XCTestCase {

    private func makeSUT(
        runs: [Run] = [],
        scores: [String: [MeasureScore]] = [:]
    ) -> ProtocolDashboardViewModel {
        ProtocolDashboardViewModel(
            cbtProtocol: SampleData.lateNightRumination,
            runRepository: MockRunRepository(runs: runs),
            measureRepository: MockMeasureRepository(scores: scores)
        )
    }

    private func makeRun(
        emotionBefore: Int = 60,
        emotionAfter: Int = 40,
        beliefBefore: Int = 70,
        beliefAfter: Int = 50,
        daysAgo: Double = 0
    ) -> Run {
        let start = Date().addingTimeInterval(-daysAgo * 86400)
        return Run(
            protocolID: SampleData.lateNightRumination.id,
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(180),
            emotions: [EmotionRating(emotion: .anxiety, intensity: emotionBefore)],
            beliefStrengthBefore: beliefBefore,
            chosenInterventions: ["delay_01"],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: emotionAfter)],
            beliefStrengthAfter: beliefAfter,
            outcomeTags: [.intensityDropped],
            helpfulnessRating: .helpful,
            completionStatus: .completed
        )
    }

    func testLoadWithMockDataPopulatesStats() async {
        let runs = (0..<3).map { makeRun(daysAgo: Double($0)) }
        let vm = makeSUT(runs: runs)
        await vm.loadDashboard()
        XCTAssertNotNil(vm.stats)
        XCTAssertEqual(vm.stats?.completedRunCount, 3)
    }

    func testLoadWithZeroRunsShowsZeros() async {
        let vm = makeSUT()
        await vm.loadDashboard()
        XCTAssertNotNil(vm.stats)
        XCTAssertEqual(vm.stats?.completedRunCount, 0)
        XCTAssertNil(vm.stats?.averageEmotionChange)
    }

    func testMeasureScoresLoadedFromRepo() async {
        let scores: [String: [MeasureScore]] = [
            "GAD-7": [MeasureScore(totalScore: 12)]
        ]
        let vm = makeSUT(scores: scores)
        await vm.loadDashboard()
        XCTAssertEqual(vm.measureScores["GAD-7"]?.count, 1)
        XCTAssertEqual(vm.measureScores["GAD-7"]?.first?.totalScore, 12)
    }

    func testCompletionCandidateDetected() async {
        let runs = (0..<5).map { makeRun(
            emotionBefore: 60, emotionAfter: 30,
            beliefBefore: 50, beliefAfter: 25,
            daysAgo: Double($0)
        )}
        let vm = makeSUT(runs: runs)
        await vm.loadDashboard()
        XCTAssertNotNil(vm.completionCandidate)
        XCTAssertTrue(vm.completionCandidate?.isCandidate ?? false)
    }

    func testBeliefTrendDataAvailable() async {
        let runs = (0..<3).map { makeRun(daysAgo: Double($0)) }
        let vm = makeSUT(runs: runs)
        await vm.loadDashboard()
        XCTAssertEqual(vm.stats?.beliefStrengthTrend.count, 3)
    }

    func testOutcomeTagCountsAvailable() async {
        let runs = [
            makeRun(),
            makeRun()
        ]
        let vm = makeSUT(runs: runs)
        await vm.loadDashboard()
        XCTAssertEqual(vm.stats?.outcomeTagCounts[.intensityDropped], 2)
    }

    func testLoadingStateToggles() async {
        let vm = makeSUT()
        XCTAssertFalse(vm.isLoading)
        await vm.loadDashboard()
        XCTAssertFalse(vm.isLoading)
    }

    func testNotCandidateWithFewRuns() async {
        let runs = [makeRun()]
        let vm = makeSUT(runs: runs)
        await vm.loadDashboard()
        XCTAssertNotNil(vm.completionCandidate)
        XCTAssertFalse(vm.completionCandidate?.isCandidate ?? true)
    }
}
