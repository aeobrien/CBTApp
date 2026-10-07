import Foundation

/// Configurable mock for VoiceInputServiceProtocol, for testing and previews.
public final class MockVoiceInputService: VoiceInputServiceProtocol, @unchecked Sendable {

    // MARK: - Configuration

    public var stubbedTranscription: String = "Test transcription"
    public var stubbedPermissionGranted: Bool = true
    public var shouldThrowOnStart: Bool = false
    public var shouldThrowOnStop: Bool = false
    public var shouldThrowOnPrepare: Bool = false

    // MARK: - State

    public var state: VoiceTranscriptionState = .idle
    public var modelStatus: VoiceModelStatus = .ready
    public var isMicrophonePermissionGranted: Bool = true

    // MARK: - Call tracking

    public private(set) var prepareModelCallCount = 0
    public private(set) var startRecordingCallCount = 0
    public private(set) var stopRecordingCallCount = 0
    public private(set) var cancelRecordingCallCount = 0
    public private(set) var requestPermissionCallCount = 0

    // MARK: - Init

    public init(
        stubbedTranscription: String = "Test transcription",
        stubbedPermissionGranted: Bool = true
    ) {
        self.stubbedTranscription = stubbedTranscription
        self.stubbedPermissionGranted = stubbedPermissionGranted
        self.isMicrophonePermissionGranted = stubbedPermissionGranted
    }

    // MARK: - VoiceInputServiceProtocol

    public func prepareModel() async throws {
        prepareModelCallCount += 1
        if shouldThrowOnPrepare {
            throw VoiceInputError.modelLoadFailed("Mock prepare failure")
        }
        modelStatus = .ready
    }

    public func startRecording() async throws {
        startRecordingCallCount += 1
        if shouldThrowOnStart {
            throw VoiceInputError.recordingFailed("Mock start failure")
        }
        state = .recording
    }

    public func stopRecording() async throws -> String {
        stopRecordingCallCount += 1
        if shouldThrowOnStop {
            throw VoiceInputError.transcriptionFailed("Mock stop failure")
        }
        state = .result(stubbedTranscription)
        return stubbedTranscription
    }

    public func cancelRecording() {
        cancelRecordingCallCount += 1
        state = .idle
    }

    public func requestMicrophonePermission() async -> Bool {
        requestPermissionCallCount += 1
        isMicrophonePermissionGranted = stubbedPermissionGranted
        return stubbedPermissionGranted
    }
}

/// Errors thrown by voice input operations.
public enum VoiceInputError: Error, LocalizedError, Sendable {
    case modelLoadFailed(String)
    case recordingFailed(String)
    case transcriptionFailed(String)
    case permissionDenied

    public var errorDescription: String? {
        switch self {
        case .modelLoadFailed(let msg): return "Model load failed: \(msg)"
        case .recordingFailed(let msg): return "Recording failed: \(msg)"
        case .transcriptionFailed(let msg): return "Transcription failed: \(msg)"
        case .permissionDenied: return "Microphone permission denied"
        }
    }
}
