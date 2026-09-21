import XCTest
@testable import Features
@testable import Domain

@MainActor
final class OnboardingFlowViewModelTests: XCTestCase {

    /// Thread-safe completion tracker for @Sendable closures.
    private final class CompletionTracker: @unchecked Sendable {
        var completed = false
    }

    private func makeSUT(
        onComplete: @escaping @Sendable () -> Void = {}
    ) -> OnboardingFlowViewModel {
        OnboardingFlowViewModel(onComplete: onComplete)
    }

    // MARK: - Initial State

    func testInitialScreenIsWelcome() {
        let vm = makeSUT()
        XCTAssertEqual(vm.currentScreen, .welcome)
        XCTAssertTrue(vm.navigationPath.isEmpty)
    }

    // MARK: - Advance

    func testAdvanceFromWelcomeToHotThoughts() {
        let vm = makeSUT()
        vm.advance()
        XCTAssertEqual(vm.currentScreen, .hotThoughts)
    }

    func testAdvanceThroughAllScreens() {
        let vm = makeSUT()

        vm.advance()
        XCTAssertEqual(vm.currentScreen, .hotThoughts)

        vm.advance()
        XCTAssertEqual(vm.currentScreen, .maintainingBehaviours)

        vm.advance()
        XCTAssertEqual(vm.currentScreen, .testing)

        vm.advance()
        XCTAssertEqual(vm.currentScreen, .ready)
    }

    func testAdvanceAtLastScreenDoesNothing() {
        let vm = makeSUT()
        // Navigate to ready
        for _ in OnboardingScreen.allCases.dropLast() {
            vm.advance()
        }
        XCTAssertEqual(vm.currentScreen, .ready)

        vm.advance()
        XCTAssertEqual(vm.currentScreen, .ready)
        XCTAssertEqual(vm.navigationPath.count, 4)
    }

    // MARK: - Go Back

    func testGoBackPopsScreen() {
        let vm = makeSUT()
        vm.advance() // → hotThoughts
        vm.advance() // → maintainingBehaviours

        vm.goBack()
        XCTAssertEqual(vm.currentScreen, .hotThoughts)
    }

    func testGoBackAtWelcomeDoesNothing() {
        let vm = makeSUT()
        vm.goBack()
        XCTAssertEqual(vm.currentScreen, .welcome)
        XCTAssertTrue(vm.navigationPath.isEmpty)
    }

    // MARK: - Finish & Skip

    func testFinishCallsOnComplete() {
        let tracker = CompletionTracker()
        let vm = makeSUT { tracker.completed = true }

        vm.finish()
        XCTAssertTrue(tracker.completed)
    }

    func testSkipCallsOnComplete() {
        let tracker = CompletionTracker()
        let vm = makeSUT { tracker.completed = true }

        vm.skip()
        XCTAssertTrue(tracker.completed)
    }

    // MARK: - Navigation Path

    func testNavigationPathTracksScreens() {
        let vm = makeSUT()
        XCTAssertEqual(vm.navigationPath, [])

        vm.advance()
        XCTAssertEqual(vm.navigationPath, [.hotThoughts])

        vm.advance()
        XCTAssertEqual(vm.navigationPath, [.hotThoughts, .maintainingBehaviours])

        vm.goBack()
        XCTAssertEqual(vm.navigationPath, [.hotThoughts])
    }
}
