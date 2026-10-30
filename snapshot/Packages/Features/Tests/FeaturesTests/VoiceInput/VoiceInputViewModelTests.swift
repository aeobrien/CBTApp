import XCTest
@testable import Features
@testable import Domain

@MainActor
final class VoiceInputViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        transcription: String = "Test transcription",
        permissionGranted: Bool = true
    ) -> (VoiceInputViewModel, MockVoiceInputService) {
        let mock = MockVoiceInputService(
            stubbedTranscription: transcription,
            stubbedPermissionGranted: permissionGranted
        )
        let vm = VoiceInputViewModel(voiceService: mock)
        return (vm, mock)
    }

    // MARK: - Initial State

    func testInitialStateIsIdleNotRecording() {
        let (vm, _) = makeSUT()
        XCTAssertFalse(vm.isRecording)
        XCTAssertFalse(vm.isShowingTranscription)
        XCTAssertEqual(vm.transcribedText, "")
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - Toggle Recording

    func testToggleRecordingStartsRecording() async {
        let (vm, mock) = makeSUT()
        await vm.toggleRecording()

        XCTAssertTrue(vm.isRecording)
        XCTAssertEqual(mock.startRecordingCallCount, 1)
    }

    func testToggleRecordingWhileRecordingStopsAndShowsTranscription() async {
        let (vm, mock) = makeSUT(transcription: "Hello world")

        // Start
        await vm.toggleRecording()
        XCTAssertTrue(vm.isRecording)

        // Stop
        await vm.toggleRecording()
        XCTAssertFalse(vm.isRecording)
        XCTAssertTrue(vm.isShowingTranscription)
        XCTAssertEqual(mock.stopRecordingCallCount, 1)
    }

    // MARK: - Confirm / Cancel

    func testConfirmTranscriptionReturnsTextAndResets() async {
        let (vm, _) = makeSUT(transcription: "hello world")
        await vm.toggleRecording()
        await vm.toggleRecording()

        let result = vm.confirmTranscription()
        XCTAssertEqual(result, "Hello world.")
        XCTAssertFalse(vm.isShowingTranscription)
        XCTAssertEqual(vm.transcribedText, "")
    }

    func testCancelTranscriptionHidesOverlay() async {
        let (vm, _) = makeSUT(transcription: "hello")
        await vm.toggleRecording()
        await vm.toggleRecording()

        vm.cancelTranscription()
        XCTAssertFalse(vm.isShowingTranscription)
        XCTAssertEqual(vm.transcribedText, "")
    }

    // MARK: - Permission Denied

    func testPermissionDeniedShowsAlert() async {
        let (vm, _) = makeSUT(permissionGranted: false)
        await vm.toggleRecording()

        XCTAssertTrue(vm.isShowingPermissionDenied)
        XCTAssertFalse(vm.isRecording)
    }

    // MARK: - Error Handling

    func testErrorFromServiceSurfacesInErrorMessage() async {
        let (vm, mock) = makeSUT()
        mock.shouldThrowOnStart = true
        await vm.toggleRecording()

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isRecording)
    }

    // MARK: - Post-Processor

    func testPostProcessorAppliedToResult() async {
        let (vm, _) = makeSUT(transcription: "hello world")
        await vm.toggleRecording()
        await vm.toggleRecording()

        // Post-processor capitalises and adds period
        XCTAssertEqual(vm.transcribedText, "Hello world.")
    }

    // MARK: - Cancel During Recording

    func testCancelDuringRecordingCallsCancelRecording() async {
        let (vm, mock) = makeSUT()
        await vm.toggleRecording()
        XCTAssertTrue(vm.isRecording)

        // Cancel while recording (user cancels transcription before stopping)
        vm.cancelTranscription()
        XCTAssertFalse(vm.isShowingTranscription)
    }

    // MARK: - Model Preparation

    func testModelPreparationTriggeredOnFirstUse() async {
        let (vm, mock) = makeSUT()
        await vm.toggleRecording()

        XCTAssertEqual(mock.prepareModelCallCount, 1)
    }

    // MARK: - Multiple Cycles

    func testMultipleToggleCyclesWorkCorrectly() async {
        let (vm, mock) = makeSUT(transcription: "First")

        // Cycle 1
        await vm.toggleRecording()
        await vm.toggleRecording()
        _ = vm.confirmTranscription()

        // Cycle 2
        mock.stubbedTranscription = "Second"
        await vm.toggleRecording()
        await vm.toggleRecording()

        XCTAssertTrue(vm.isShowingTranscription)
        XCTAssertEqual(mock.startRecordingCallCount, 2)
        XCTAssertEqual(mock.stopRecordingCallCount, 2)
    }
}
