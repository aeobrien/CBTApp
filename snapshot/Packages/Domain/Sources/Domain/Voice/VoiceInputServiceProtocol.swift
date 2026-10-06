import Foundation

/// The current state of a voice transcription operation.
public enum VoiceTranscriptionState: Sendable, Equatable {
    case idle
    case preparing
    case recording
    case transcribing
    case result(String)
    case error(String)
}

/// The status of the on-device speech model.
public enum VoiceModelStatus: Sendable, Equatable {
    case notDownloaded
    case downloading(progress: Double)
    case ready
    case error(String)
}

/// Testable protocol for voice input, consumed by ViewModels.
public protocol VoiceInputServiceProtocol: AnyObject, Sendable {
    var state: VoiceTranscriptionState { get }
    var modelStatus: VoiceModelStatus { get }
    var isMicrophonePermissionGranted: Bool { get }

    /// Download / initialise the speech model.
    func prepareModel() async throws

    /// Begin capturing audio from the microphone.
    func startRecording() async throws

    /// Stop capturing and return the transcribed text.
    func stopRecording() async throws -> String

    /// Abort recording without transcribing.
    func cancelRecording()

    /// Request microphone permission from the user. Returns `true` if granted.
    func requestMicrophonePermission() async -> Bool
}
