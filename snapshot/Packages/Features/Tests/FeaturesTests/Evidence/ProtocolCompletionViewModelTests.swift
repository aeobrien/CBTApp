import XCTest
@testable import Features
@testable import Domain

@MainActor
final class ProtocolCompletionViewModelTests: XCTestCase {

    private func makeSUT() -> (ProtocolCompletionViewModel, MockProtocolRepository) {
        let repo = MockProtocolRepository(protocols: [SampleData.lateNightRumination])
        let candidate = CompletionCandidate(
            isCandidate: true,
            reason: "Sustained improvement",
            suggestedKeyTrigger: "Lying in bed unable to sleep",
            suggestedUpdatedBelief: "If I don't replay it, I'll miss something important",
            suggestedBestInterventionID: "delay_01",
            suggestedBestInterventionTitle: "10-minute delay"
        )
        let vm = ProtocolCompletionViewModel(
            cbtProtocol: SampleData.lateNightRumination,
            candidate: candidate,
            protocolRepository: repo
        )
        return (vm, repo)
    }

    func testCompleteSetsStatusToCompleted() async throws {
        let (vm, repo) = makeSUT()
        vm.learningNote = "I learned to let go"
        await vm.completeProtocol()
        let saved = try await repo.fetch(id: SampleData.lateNightRumination.id)
        XCTAssertEqual(saved?.status, .completed)
    }

    func testRelapseCardPopulatedFromCandidate() async {
        let (vm, _) = makeSUT()
        vm.learningNote = "Key takeaway"
        await vm.completeProtocol()
        XCTAssertNotNil(vm.relapseCard)
        XCTAssertEqual(vm.relapseCard?.keyTrigger, "Lying in bed unable to sleep")
        XCTAssertEqual(vm.relapseCard?.bestInterventionTitle, "10-minute delay")
    }

    func testLearningNoteSavedToCompletionSummary() async throws {
        let (vm, repo) = makeSUT()
        vm.learningNote = "Rumination is not problem-solving"
        await vm.completeProtocol()
        let saved = try await repo.fetch(id: SampleData.lateNightRumination.id)
        XCTAssertEqual(saved?.completionSummary, "Rumination is not problem-solving")
    }

    func testProtocolUpdatedViaRepository() async throws {
        let (vm, repo) = makeSUT()
        await vm.completeProtocol()
        let saved = try await repo.fetch(id: SampleData.lateNightRumination.id)
        XCTAssertNotNil(saved?.relapsePreventionCard)
        XCTAssertEqual(saved?.status, .completed)
    }

    func testRelapseCardFieldsMatchExpected() async {
        let (vm, _) = makeSUT()
        vm.learningNote = "Summary note"
        await vm.completeProtocol()
        XCTAssertEqual(vm.relapseCard?.bestInterventionID, "delay_01")
        XCTAssertEqual(vm.relapseCard?.summaryNote, "Summary note")
        XCTAssertEqual(vm.relapseCard?.updatedBelief, "If I don't replay it, I'll miss something important")
    }
}
