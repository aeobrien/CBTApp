import XCTest
@testable import Features
@testable import Domain

@MainActor
final class MeasureAdminViewModelTests: XCTestCase {

    private func makeSUT(
        definition: MeasureDefinition = .phq9,
        scores: [String: [MeasureScore]] = [:]
    ) -> MeasureAdminViewModel {
        MeasureAdminViewModel(
            definition: definition,
            measureRepository: MockMeasureRepository(scores: scores)
        )
    }

    func testInitialState() {
        let vm = makeSUT()
        XCTAssertEqual(vm.currentItemIndex, 0)
        XCTAssertTrue(vm.responses.isEmpty)
        XCTAssertFalse(vm.isComplete)
        XCTAssertEqual(vm.totalScore, 0)
    }

    func testSelectResponseAddsToResponses() {
        let vm = makeSUT()
        vm.selectResponse(2)
        XCTAssertEqual(vm.responses, [2])
    }

    func testAdvanceIncrementsIndex() {
        let vm = makeSUT()
        vm.selectResponse(1)
        vm.advance()
        XCTAssertEqual(vm.currentItemIndex, 1)
    }

    func testGoBackDecrementsIndex() {
        let vm = makeSUT()
        vm.selectResponse(1)
        vm.advance()
        vm.goBack()
        XCTAssertEqual(vm.currentItemIndex, 0)
    }

    func testCannotGoBackFromItemZero() {
        let vm = makeSUT()
        vm.goBack()
        XCTAssertEqual(vm.currentItemIndex, 0)
    }

    func testCompleteAfterAllItems() {
        let vm = makeSUT()
        // Answer all 9 PHQ-9 items
        for i in 0..<9 {
            vm.selectResponse(i < 8 ? 1 : 2)
            vm.advance()
        }
        XCTAssertTrue(vm.isComplete)
    }

    func testPHQ9ScoringSum() {
        let vm = makeSUT()
        // Answer all 9 items with value 2
        for _ in 0..<9 {
            vm.selectResponse(2)
            vm.advance()
        }
        XCTAssertEqual(vm.totalScore, 18)
        XCTAssertEqual(vm.scoringBand?.severity, .moderatelySevere)
    }

    func testSubmitSavesScore() async {
        let repo = MockMeasureRepository()
        let vm = MeasureAdminViewModel(definition: .phq9, measureRepository: repo)
        vm.selectResponse(1)
        vm.advance()
        // Complete remaining items
        for _ in 1..<9 {
            vm.selectResponse(0)
            vm.advance()
        }
        await vm.submit()
        let saved = await repo.scores["PHQ-9"]
        XCTAssertEqual(saved?.count, 1)
        XCTAssertEqual(saved?.first?.totalScore, 1)
    }
}
