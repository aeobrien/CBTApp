import XCTest
@testable import Features
@testable import Domain

@MainActor
final class WeeklyReviewViewModelTests: XCTestCase {

    private func makeSUT(runs: [Run] = []) -> WeeklyReviewViewModel {
        WeeklyReviewViewModel(
            cbtProtocol: SampleData.lateNightRumination,
            runRepository: MockRunRepository(runs: runs),
            measureRepository: MockMeasureRepository()
        )
    }

    private func makeRun(
        emotionBefore: Int = 60,
        emotionAfter: Int = 40,
        tags: [OutcomeTag] = [.intensityDropped],
        daysAgo: Double = 0
    ) -> Run {
        let start = Date().addingTimeInterval(-daysAgo * 86400)
        return Run(
            protocolID: SampleData.lateNightRumination.id,
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(180),
            emotions: [EmotionRating(emotion: .anxiety, intensity: emotionBefore)],
            beliefStrengthBefore: 70,
            chosenInterventions: ["delay_01"],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: emotionAfter)],
            beliefStrengthAfter: 50,
            outcomeTags: tags,
            helpfulnessRating: .helpful,
            completionStatus: .completed
        )
    }

    func testLoadGeneratesInsightsFromRecentRuns() async {
        let runs = (0..<4).map { makeRun(daysAgo: Double($0)) }
        let vm = makeSUT(runs: runs)
        await vm.loadReview()
        XCTAssertFalse(vm.insights.isEmpty)
    }

    func testEmptyRunHistoryNoInsights() async {
        let vm = makeSUT()
        await vm.loadReview()
        XCTAssertTrue(vm.insights.isEmpty)
    }

    func testLoadingStateToggles() async {
        let vm = makeSUT()
        XCTAssertFalse(vm.isLoading)
        await vm.loadReview()
        XCTAssertFalse(vm.isLoading)
    }

    func testInsightsSortedByPriority() async {
        let runs = (0..<5).map { makeRun(daysAgo: Double($0)) }
        let vm = makeSUT(runs: runs)
        await vm.loadReview()
        for i in 0..<(vm.insights.count - 1) {
            XCTAssertLessThanOrEqual(vm.insights[i].priority, vm.insights[i + 1].priority)
        }
    }

    func testRevisionSuggestionWhenWorsening() async {
        let runs = (0..<5).map { makeRun(tags: [.gotWorse], daysAgo: Double($0)) }
        let vm = makeSUT(runs: runs)
        await vm.loadReview()
        XCTAssertTrue(vm.insights.contains { $0.type == .revisionSuggestion })
    }
}
