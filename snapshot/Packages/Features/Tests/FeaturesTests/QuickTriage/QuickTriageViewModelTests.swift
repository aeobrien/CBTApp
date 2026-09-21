import XCTest
@testable import Features
@testable import Domain

@MainActor
final class QuickTriageViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        protocols: [CBTProtocol] = SampleData.allProtocols
    ) -> QuickTriageViewModel {
        QuickTriageViewModel(protocols: protocols)
    }

    // MARK: - Step Navigation

    func testInitialStepIsZero() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.step, 0)
    }

    func testAdvanceIncrementsStep() {
        let vm = makeViewModel()
        vm.selectedUrge = .ruminate
        vm.advance()
        XCTAssertEqual(vm.step, 1)
    }

    func testGoBackDecrementsStep() {
        let vm = makeViewModel()
        vm.selectedUrge = .ruminate
        vm.advance()
        XCTAssertEqual(vm.step, 1)
        vm.goBack()
        XCTAssertEqual(vm.step, 0)
    }

    func testGoBackDoesNotGoBelowZero() {
        let vm = makeViewModel()
        vm.goBack()
        XCTAssertEqual(vm.step, 0)
    }

    func testCannotAdvancePastStep3() {
        let vm = makeViewModel()
        vm.selectedUrge = .ruminate
        vm.selectedTheme = .loss
        vm.advance() // -> 1
        vm.advance() // -> 2
        vm.advance() // -> 3 (runs matching)
        vm.advance() // should stay at 3
        XCTAssertEqual(vm.step, 3)
    }

    // MARK: - canAdvance

    func testCanAdvanceRequiresUrgeAtStep0() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canAdvance)
        vm.selectedUrge = .check
        XCTAssertTrue(vm.canAdvance)
    }

    func testCanAdvanceRequiresThemeAtStep1() {
        let vm = makeViewModel()
        vm.selectedUrge = .ruminate
        vm.advance()
        XCTAssertFalse(vm.canAdvance)
        vm.selectedTheme = .uncertainty
        XCTAssertTrue(vm.canAdvance)
    }

    // MARK: - Matching & Callbacks

    func testSelectMatchCallsCallback() {
        let expectation = expectation(description: "callback called")
        var receivedProtocol: CBTProtocol?

        let vm = QuickTriageViewModel(
            protocols: SampleData.allProtocols,
            onSelectProtocol: { proto in
                receivedProtocol = proto
                expectation.fulfill()
            }
        )

        let match = TriageMatcher.ScoredMatch(
            cbtProtocol: SampleData.lateNightRumination,
            score: 3
        )
        vm.selectMatch(match)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedProtocol?.id, SampleData.lateNightRumination.id)
    }
}
