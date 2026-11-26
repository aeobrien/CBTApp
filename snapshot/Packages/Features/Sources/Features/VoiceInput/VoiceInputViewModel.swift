import Foundation
import Domain
import Utilities

/// Drives voice recording state for a single text field.
@Observable
@MainActor
public final class VoiceInputViewModel {

    // MARK: - Dependencies

    private let voiceService: any VoiceInputServiceProtocol
    private let logger = CBTLogger.logger(for: .voiceInput)

    // MARK: - State

    public var isRecording: Bool = false
    public var transcribedText: String = ""
    public var isShowingTranscription: Bool = false
    public var errorMessage: String?
    public var isShowingPermissionDenied: Bool = false
    private var hasPreparedModel = false

    // MARK: - Init

    public nonisolated init(voiceService: any VoiceInputServiceProtocol) {
        self.voiceService = voiceService
    }

    // MARK: - Actions

    /// Toggle recording on/off. On stop, shows transcription edit sheet.
    public func toggleRecording() async {
        if isRecording {
            await stopAndTranscribe()
        } else {
            await startRecording()
        }
    }

    /// Confirm the (possibly edited) transcription for insertion.
    public func confirmTranscription() -> String {
        let text = transcribedText
        transcribedText = ""
        isShowingTranscription = false
        logger.debug("Transcription confirmed: \(text.prefix(50))")
        return text
    }

    /// Cancel transcription without inserting.
    public func cancelTranscription() {
        transcribedText = ""
        isShowingTranscription = false
        logger.debug("Transcription cancelled")
    }

    // MARK: - Private

    private func startRecording() async {
        errorMessage = nil

        // Check permission
        if !voiceService.isMicrophonePermissionGranted {
            let granted = await voiceService.requestMicrophonePermission()
            if !granted {
                isShowingPermissionDenied = true
                logger.info("Microphone permission denied")
                return
            }
        }

        // Prepare model on first use
        if !hasPreparedModel {
            do {
                try await voiceService.prepareModel()
                hasPreparedModel = true
            } catch {
                errorMessage = error.localizedDescription
                logger.error("Model preparation failed: \(error.localizedDescription)")
                return
            }
        }

        // Start recording
        do {
            try await voiceService.startRecording()
            isRecording = true
            logger.info("Recording started")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Start recording failed: \(error.localizedDescription)")
        }
    }

    private func stopAndTranscribe() async {
        do {
            let rawText = try await voiceService.stopRecording()
            isRecording = false
            let processed = TranscriptionPostProcessor.process(rawText)
            transcribedText = processed
            if !processed.isEmpty {
                isShowingTranscription = true
            }
            logger.info("Recording stopped, transcription ready")
        } catch {
            isRecording = false
            errorMessage = error.localizedDescription
            logger.error("Stop recording failed: \(error.localizedDescription)")
        }
    }
}
