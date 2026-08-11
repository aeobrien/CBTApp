import XCTest
@testable import Domain

final class TranscriptionPostProcessorTests: XCTestCase {

    // MARK: - TranscriptionPostProcessor

    func testEmptyStringReturnsEmpty() {
        XCTAssertEqual(TranscriptionPostProcessor.process(""), "")
    }

    func testTrimsWhitespace() {
        XCTAssertEqual(TranscriptionPostProcessor.process("  hello  "), "Hello.")
    }

    func testCapitalisesFirstCharacter() {
        XCTAssertEqual(TranscriptionPostProcessor.process("hello world"), "Hello world.")
    }

    func testAddsPeriodWhenNoTrailingPunctuation() {
        XCTAssertEqual(TranscriptionPostProcessor.process("this is a test"), "This is a test.")
    }

    func testPreservesExistingPeriod() {
        XCTAssertEqual(TranscriptionPostProcessor.process("already done."), "Already done.")
    }

    func testPreservesQuestionMark() {
        XCTAssertEqual(TranscriptionPostProcessor.process("is this right?"), "Is this right?")
    }

    func testPreservesExclamationMark() {
        XCTAssertEqual(TranscriptionPostProcessor.process("watch out!"), "Watch out!")
    }

    func testSingleCharacter() {
        XCTAssertEqual(TranscriptionPostProcessor.process("a"), "A.")
    }

    func testOnlyWhitespaceReturnsEmpty() {
        XCTAssertEqual(TranscriptionPostProcessor.process("   "), "")
    }

    func testUnicodeHandling() {
        XCTAssertEqual(TranscriptionPostProcessor.process("café latte"), "Café latte.")
    }

    func testAlreadyCapitalised() {
        XCTAssertEqual(TranscriptionPostProcessor.process("Hello"), "Hello.")
    }
}

final class MockVoiceInputServiceTests: XCTestCase {

    func testCallTrackingForStartStopCancel() async throws {
        let mock = MockVoiceInputService()
        try await mock.startRecording()
        _ = try await mock.stopRecording()
        mock.cancelRecording()

        XCTAssertEqual(mock.startRecordingCallCount, 1)
        XCTAssertEqual(mock.stopRecordingCallCount, 1)
        XCTAssertEqual(mock.cancelRecordingCallCount, 1)
    }

    func testConfigurableTranscriptionResult() async throws {
        let mock = MockVoiceInputService(stubbedTranscription: "Custom result")
        try await mock.startRecording()
        let result = try await mock.stopRecording()

        XCTAssertEqual(result, "Custom result")
    }

    func testStateTransitions() async throws {
        let mock = MockVoiceInputService()
        XCTAssertEqual(mock.state, .idle)

        try await mock.startRecording()
        XCTAssertEqual(mock.state, .recording)

        _ = try await mock.stopRecording()
        XCTAssertEqual(mock.state, .result("Test transcription"))
    }

    func testPermissionSimulation() async {
        let mock = MockVoiceInputService(stubbedPermissionGranted: false)
        let granted = await mock.requestMicrophonePermission()

        XCTAssertFalse(granted)
        XCTAssertFalse(mock.isMicrophonePermissionGranted)
        XCTAssertEqual(mock.requestPermissionCallCount, 1)
    }

    func testPrepareModelCallCount() async throws {
        let mock = MockVoiceInputService()
        try await mock.prepareModel()

        XCTAssertEqual(mock.prepareModelCallCount, 1)
        XCTAssertEqual(mock.modelStatus, .ready)
    }

    func testStartThrowsWhenConfigured() async {
        let mock = MockVoiceInputService()
        mock.shouldThrowOnStart = true

        do {
            try await mock.startRecording()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is VoiceInputError)
        }
    }
}
