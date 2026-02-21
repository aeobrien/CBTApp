import Foundation
import Domain
import DesignSystem
import Utilities

/// Protocol for the RunFlowViewModel, defined so tests can verify behaviour.
@MainActor
public protocol RunFlowViewModelProtocol: AnyObject {
    var navigationPath: [RunFlowStep] { get }
    var currentStep: RunFlowStep { get }

    // Screen A
    var searchQuery: String { get set }
    var allProtocols: [CBTProtocol] { get }
    var filteredProtocols: [CBTProtocol] { get }
    func selectProtocol(_ cbtProtocol: CBTProtocol) async

    // Screen B
    var situation: String { get set }
    var selectedHotThought: String? { get set }
    var customHotThought: String { get set }
    var emotionRatings: [EmotionRating] { get set }
    var selectedBodySignals: Set<BodySignal> { get set }
    var selectedUrge: UrgeType? { get set }
    var beliefStrengthBefore: Double { get set }

    // Screen C
    var displayedHotThought: String { get }
    var predictionResponse: String { get set }
    var alternativeResponse: String { get set }

    // Screen D
    var currentIntervention: InterventionInstance? { get }
    var checkedSteps: Set<Int> { get set }
    func switchIntervention()

    // Screen E
    var emotionRatingsAfter: [EmotionRating] { get set }
    var beliefStrengthAfter: Double { get set }
    var selectedOutcomeTags: Set<OutcomeTag> { get set }
    var learningNote: String { get set }
    var forwardPlan: String { get set }

    // Screen F
    var summaryText: String { get }
    var helpfulnessRating: HelpfulnessRating? { get set }

    // Navigation
    func advance() async
    func skipCapture() async
    func skipDiscovery() async
    func finishRun() async
}

/// Drives the entire Run Mode flow across 6 screens.
@Observable
@MainActor
public final class RunFlowViewModel: RunFlowViewModelProtocol {

    // MARK: - Dependencies

    private let protocolRepository: any ProtocolRepositoryProtocol
    private let runRepository: any RunRepositoryProtocol
    private let safetySystem: any SafetySystemProtocol
    private let logger: ModuleLogger

    /// Optional voice input service for speech-to-text on text fields.
    public nonisolated(unsafe) var voiceInputService: (any VoiceInputServiceProtocol)?

    // MARK: - Navigation

    public var navigationPath: [RunFlowStep] = []

    public var currentStep: RunFlowStep {
        navigationPath.last ?? .protocolSelection
    }

    // MARK: - Screen A: Protocol Selection

    public var searchQuery: String = ""
    public var allProtocols: [CBTProtocol] = []

    public var filteredProtocols: [CBTProtocol] {
        guard !searchQuery.isEmpty else { return allProtocols }
        let query = searchQuery.lowercased()
        return allProtocols.filter {
            $0.name.lowercased().contains(query) ||
            $0.whenToUse.contains { $0.lowercased().contains(query) } ||
            $0.tags.contains { $0.lowercased().contains(query) }
        }
    }

    // MARK: - Selected protocol info (for views)

    public var hotThoughtTemplates: [String] {
        selectedProtocol?.hotThoughtTemplates ?? []
    }

    // MARK: - Screen B: Capture

    public var situation: String = ""
    public var selectedHotThought: String?
    public var customHotThought: String = ""
    public var emotionRatings: [EmotionRating] = []
    public var selectedBodySignals: Set<BodySignal> = []
    public var selectedUrge: UrgeType?
    public var beliefStrengthBefore: Double = 50

    // MARK: - Screen C: Guided Discovery

    public var displayedHotThought: String {
        if let selected = selectedHotThought, !selected.isEmpty {
            return selected
        }
        if !customHotThought.isEmpty {
            return customHotThought
        }
        return selectedProtocol?.hotThoughtTemplates.first ?? ""
    }

    public var predictionResponse: String = ""
    public var alternativeResponse: String = ""

    // MARK: - Screen D: Intervention

    public var currentIntervention: InterventionInstance?
    public var checkedSteps: Set<Int> = []
    public var timerModel: TimerModel?

    private var interventionCandidates: [InterventionInstance] = []
    private var interventionIndex: Int = 0

    // MARK: - Screen E: Outcome

    public var emotionRatingsAfter: [EmotionRating] = []
    public var beliefStrengthAfter: Double = 50
    public var selectedOutcomeTags: Set<OutcomeTag> = []
    public var learningNote: String = ""
    public var forwardPlan: String = ""

    // MARK: - Screen F: Summary

    public var summaryText: String = ""
    public var helpfulnessRating: HelpfulnessRating?

    // MARK: - Safety

    public var pendingSafetyAlert: SafetyAlert?

    // MARK: - Internal state

    private var currentRun: Run?
    private var selectedProtocol: CBTProtocol?
    private var engine: ProtocolEngine?
    private let correlationID: String

    // MARK: - Init

    public nonisolated init(
        protocolRepository: any ProtocolRepositoryProtocol,
        runRepository: any RunRepositoryProtocol,
        safetySystem: (any SafetySystemProtocol)? = nil,
        voiceInputService: (any VoiceInputServiceProtocol)? = nil,
        logger: ModuleLogger = CBTLogger.logger(for: .runMode)
    ) {
        self.protocolRepository = protocolRepository
        self.runRepository = runRepository
        self.safetySystem = safetySystem ?? MockSafetySystem()
        self.voiceInputService = voiceInputService
        self.logger = logger
        self.correlationID = String(UUID().uuidString.prefix(8).lowercased())
    }

    // MARK: - Load

    /// Load protocols on appear.
    public func loadProtocols() async {
        logger.debug("Loading protocols", correlationID: correlationID)
        do {
            allProtocols = try await protocolRepository.fetchAll(status: .active)
            logger.info("Loaded \(allProtocols.count) active protocols", correlationID: correlationID)
        } catch {
            logger.error("Failed to load protocols: \(error.localizedDescription)", correlationID: correlationID)
        }
    }

    // MARK: - Screen A: Select Protocol

    public func selectProtocol(_ cbtProtocol: CBTProtocol) async {
        logger.debug("Protocol selected: \(cbtProtocol.name)", correlationID: correlationID)
        selectedProtocol = cbtProtocol
        engine = ProtocolEngine(cbtProtocol: cbtProtocol)

        // Create a new Run with .abandoned status
        let run = Run(
            protocolID: cbtProtocol.id,
            protocolVersion: cbtProtocol.version,
            completionStatus: .abandoned
        )
        currentRun = run

        // Pre-populate emotion ratings from capture fields
        let emotionFields = cbtProtocol.captureFields.filter { $0.fieldType == .emotionPicker }
        if !emotionFields.isEmpty {
            // Start with the first few common emotions pre-loaded at 0
            emotionRatings = []
        }

        // Save initial run
        do {
            try await runRepository.save(run)
            logger.info("Initial run saved", correlationID: correlationID)
        } catch {
            logger.error("Failed to save initial run: \(error.localizedDescription)", correlationID: correlationID)
        }

        navigationPath.append(.capture)
    }

    // MARK: - Navigation

    public func advance() async {
        switch currentStep {
        case .protocolSelection:
            break // Handled by selectProtocol

        case .capture:
            // Safety scan on capture fields
            let captureText = [situation, customHotThought, selectedHotThought ?? ""].joined(separator: " ")
            if let alert = safetySystem.scanText(captureText) {
                logger.info("Safety alert in run capture: \(alert.kind.rawValue)", correlationID: correlationID)
                pendingSafetyAlert = alert
                return
            }
            syncCaptureToRun()
            await saveRun()
            navigationPath.append(.guidedDiscovery)

        case .guidedDiscovery:
            syncDiscoveryToRun()
            await saveRun()
            await recommendIntervention()
            navigationPath.append(.intervention)

        case .intervention:
            syncInterventionToRun()
            await saveRun()
            // Pre-populate after emotions with before values
            emotionRatingsAfter = emotionRatings.map { EmotionRating(emotion: $0.emotion, intensity: $0.intensity) }
            beliefStrengthAfter = beliefStrengthBefore
            navigationPath.append(.outcome)

        case .outcome:
            // Safety scan on outcome text fields
            let outcomeText = [learningNote, forwardPlan].joined(separator: " ")
            if let alert = safetySystem.scanText(outcomeText) {
                logger.info("Safety alert in run outcome: \(alert.kind.rawValue)", correlationID: correlationID)
                pendingSafetyAlert = alert
                return
            }
            syncOutcomeToRun()
            await saveRun()
            generateSummary()
            navigationPath.append(.summary)

        case .summary:
            break // Handled by finishRun
        }
    }

    public func skipCapture() async {
        logger.info("Skipping capture", correlationID: correlationID)
        currentRun?.completionStatus = .partialSkippedCapture
        await saveRun()
        await recommendIntervention()
        navigationPath.append(.intervention)
    }

    public func skipDiscovery() async {
        logger.info("Skipping guided discovery", correlationID: correlationID)
        currentRun?.completionStatus = .partialSkippedDiscovery
        await saveRun()
        await recommendIntervention()
        navigationPath.append(.intervention)
    }

    public func finishRun() async {
        logger.debug("Finishing run", correlationID: correlationID)
        currentRun?.helpfulnessRating = helpfulnessRating
        currentRun?.timestampEnd = Date()
        if currentRun?.completionStatus == .abandoned {
            currentRun?.completionStatus = .completed
        }
        await saveRun()
        logger.info("Run completed", correlationID: correlationID)
    }

    // MARK: - Screen D: Intervention switching

    public func switchIntervention() {
        guard !interventionCandidates.isEmpty else { return }
        interventionIndex = (interventionIndex + 1) % interventionCandidates.count
        currentIntervention = interventionCandidates[interventionIndex]
        checkedSteps = []
        updateTimerModel()
        logger.debug("Switched to intervention: \(currentIntervention?.title ?? "nil")", correlationID: correlationID)
    }

    // MARK: - Private: Sync state to Run

    private func syncCaptureToRun() {
        currentRun?.situation = situation.isEmpty ? nil : situation
        currentRun?.hotThought = displayedHotThought.isEmpty ? nil : displayedHotThought
        currentRun?.emotions = emotionRatings
        currentRun?.bodySignals = Array(selectedBodySignals)
        currentRun?.urge = selectedUrge
        currentRun?.beliefStrengthBefore = Int(beliefStrengthBefore)
    }

    private func syncDiscoveryToRun() {
        currentRun?.predictionResponse = predictionResponse.isEmpty ? nil : predictionResponse
        currentRun?.alternativeResponse = alternativeResponse.isEmpty ? nil : alternativeResponse
    }

    private func syncInterventionToRun() {
        if let intervention = currentIntervention {
            if currentRun?.chosenInterventions.contains(intervention.title) == false {
                currentRun?.chosenInterventions.append(intervention.title)
            }
        }
    }

    private func syncOutcomeToRun() {
        currentRun?.emotionsAfter = emotionRatingsAfter
        currentRun?.beliefStrengthAfter = Int(beliefStrengthAfter)
        currentRun?.outcomeTags = Array(selectedOutcomeTags)
        currentRun?.learningNote = learningNote.isEmpty ? nil : learningNote
        currentRun?.forwardPlan = forwardPlan.isEmpty ? nil : forwardPlan
    }

    // MARK: - Private: Persistence

    private func saveRun() async {
        guard let run = currentRun else { return }
        do {
            try await runRepository.save(run)
            logger.debug("Run saved at step: \(currentStep.rawValue)", correlationID: correlationID)
        } catch {
            logger.error("Failed to save run: \(error.localizedDescription)", correlationID: correlationID)
        }
    }

    // MARK: - Private: Intervention recommendation

    private func recommendIntervention() async {
        guard let engine else {
            logger.warning("No engine available for intervention recommendation", correlationID: correlationID)
            return
        }

        let averageIntensity: Double? = emotionRatings.isEmpty
            ? nil
            : Double(emotionRatings.map(\.intensity).reduce(0, +)) / Double(emotionRatings.count)

        let completedCount: Int
        do {
            completedCount = try await runRepository.completedRunCount(forProtocolID: currentRun?.protocolID ?? UUID())
        } catch {
            completedCount = 0
        }

        let state = JITAIState(
            capturedIntensity: averageIntensity,
            capturedHotThought: displayedHotThought.isEmpty ? nil : displayedHotThought,
            capturedPrediction: predictionResponse.isEmpty ? nil : predictionResponse,
            capturedSituation: situation.isEmpty ? nil : situation,
            capturedUrge: selectedUrge,
            completedRunCount: completedCount
        )

        let recommendation = engine.recommendIntervention(state: state)

        switch recommendation {
        case .intervention(let instance):
            currentIntervention = instance
            // Build candidates from protocol + library recommendation
            interventionCandidates = [instance] + engine.cbtProtocol.interventions.filter { $0.id != instance.id }
            interventionIndex = 0
            logger.info("Recommended intervention: \(instance.title)", correlationID: correlationID)

        case .action(let action):
            // For action suggestions, fall back to protocol's own interventions
            logger.info("JITAI suggested action: \(action.type.rawValue) — falling back to protocol interventions", correlationID: correlationID)
            interventionCandidates = engine.cbtProtocol.interventions
            currentIntervention = interventionCandidates.first
            interventionIndex = 0
        }

        updateTimerModel()
    }

    private func updateTimerModel() {
        if let intervention = currentIntervention, intervention.isTimed {
            timerModel = TimerModel(targetDuration: TimeInterval(intervention.durationEstimate))
        } else {
            timerModel = nil
        }
    }

    // MARK: - Private: Summary

    private func generateSummary() {
        guard let run = currentRun, let proto = selectedProtocol else {
            summaryText = "Run summary unavailable."
            return
        }
        summaryText = RunSummary.generate(from: run, protocolName: proto.name)
    }
}
