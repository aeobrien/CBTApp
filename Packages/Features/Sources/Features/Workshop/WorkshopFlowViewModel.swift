import Foundation
import Domain
import Utilities

/// Drives the entire Workshop flow across 10 stages.
///
/// Single ViewModel that owns all state, including per-stage conversation
/// history for guided discovery stages and progressive formulation building.
@Observable
@MainActor
public final class WorkshopFlowViewModel: WorkshopFlowViewModelProtocol {

    // MARK: - Dependencies

    private let agentService: any AgentServiceProtocol
    private let protocolRepository: any ProtocolRepositoryProtocol
    private let safetySystem: any SafetySystemProtocol
    private let logger: ModuleLogger

    // MARK: - Navigation

    public var navigationPath: [WorkshopStage] = []

    public var currentStage: WorkshopStage {
        navigationPath.last ?? .capture
    }

    // MARK: - Stage 1: Capture

    public var situation: String = ""
    public var hotThought: String = ""
    public var selectedEmotion: EmotionType?
    public var emotionIntensity: Int = 50
    public var selectedUrge: UrgeType?

    // MARK: - Guided Discovery (Stages 2, 3, 4, 6)

    public var conversationMessages: [ConversationMessage] {
        stageConversations[currentStage] ?? []
    }

    public var userInput: String = ""
    public var isAgentTyping: Bool = false

    /// Per-stage conversation history.
    private var stageConversations: [WorkshopStage: [ConversationMessage]] = [:]

    // MARK: - Stage 3 output: Maintaining behaviours

    public var identifiedBehaviours: [MaintainingBehaviour] = []

    // MARK: - Stage 4 output: Target belief

    public var confirmedTargetBelief: String = ""

    // MARK: - Stage 5: Interventions

    public var availableInterventions: [InterventionTemplate] = []
    public var selectedInterventions: [InterventionTemplate] = []

    // MARK: - Stage 6 output: Experiment

    public var experimentPrediction: String = ""
    public var experimentSteps: [String] = [""]
    public var experimentMeasures: [String] = [""]
    public var experimentSuccessCriteria: String = ""

    // MARK: - Stage 7: Capture Fields

    public var captureFields: [CaptureField] = CaptureField.defaultFields

    // MARK: - Stage 7.5: Measures

    public var selectedMeasures: [StandardisedMeasure] = []

    // MARK: - Stage 8: Review Rules

    public var reviewRules: [ReviewRule] = ReviewRule.defaults

    // MARK: - Stage 9: Generation

    public var generationState: GenerationState = .idle

    // MARK: - Formulation

    public var formulation: Formulation = Formulation()

    // MARK: - Safety

    public var pendingSafetyAlert: SafetyAlert?

    // MARK: - Revision mode

    public let isRevisionMode: Bool
    private let existingProtocol: CBTProtocol?

    // MARK: - Internal

    private let correlationID: String

    // MARK: - Init

    public nonisolated init(
        agentService: any AgentServiceProtocol,
        protocolRepository: any ProtocolRepositoryProtocol,
        safetySystem: (any SafetySystemProtocol)? = nil,
        existingProtocol: CBTProtocol? = nil,
        logger: ModuleLogger = CBTLogger.logger(for: .workshop)
    ) {
        self.agentService = agentService
        self.protocolRepository = protocolRepository
        self.safetySystem = safetySystem ?? MockSafetySystem()
        self.existingProtocol = existingProtocol
        self.isRevisionMode = existingProtocol != nil
        self.logger = logger
        self.correlationID = String(UUID().uuidString.prefix(8).lowercased())
    }

    /// Pre-fill state from an existing protocol (revision mode).
    public func loadExistingProtocol() {
        guard let proto = existingProtocol else { return }
        logger.info("Loading existing protocol for revision: \(proto.name)", correlationID: correlationID)

        // Stage 1
        if let firstLink = proto.formulation.triggerAppraisalLinks.first {
            situation = firstLink.trigger
            selectedEmotion = firstLink.emotion
            selectedUrge = firstLink.behaviour
        }
        if let firstThought = proto.hotThoughtTemplates.first {
            hotThought = firstThought
        }

        // Stage 4
        confirmedTargetBelief = proto.targets.targetBelief

        // Stage 5
        // Pre-select interventions matching protocol's intervention types
        let protoTypes = Set(proto.interventions.map(\.type))
        selectedInterventions = InterventionLibrary.allTemplates.filter { protoTypes.contains($0.type) }

        // Stage 6
        if let experiment = proto.experiments.first {
            experimentPrediction = experiment.prediction
            experimentSteps = experiment.steps
            experimentMeasures = experiment.measures
            experimentSuccessCriteria = experiment.successCriteria
        }

        // Stage 7
        captureFields = proto.captureFields

        // Stage 7.5
        selectedMeasures = proto.standardisedMeasures

        // Stage 8
        reviewRules = proto.reviewRules

        // Formulation
        formulation = proto.formulation

        // Maintaining behaviours
        identifiedBehaviours = proto.maintainingBehaviours
    }

    // MARK: - Navigation

    public func advance() async {
        logger.debug("Advancing from stage: \(currentStage.title)", correlationID: correlationID)

        switch currentStage {
        case .capture:
            guard !situation.isEmpty else {
                logger.warning("Cannot advance: situation is empty", correlationID: correlationID)
                return
            }
            // Safety scan on capture fields
            let captureText = [situation, hotThought].joined(separator: " ")
            if let alert = safetySystem.scanText(captureText) {
                logger.info("Safety alert in capture: \(alert.kind.rawValue)", correlationID: correlationID)
                pendingSafetyAlert = alert
                return
            }
            if let emotion = selectedEmotion, let urge = selectedUrge {
                formulation = FormulationBuilder.fromCapture(
                    situation: situation,
                    emotion: emotion,
                    urge: urge
                )
            }
            navigationPath.append(.recurrence)

        case .recurrence:
            navigationPath.append(.maintaining)

        case .maintaining:
            formulation = FormulationBuilder.addMaintainingCycles(
                to: formulation,
                behaviours: identifiedBehaviours
            )
            navigationPath.append(.targetBelief)

        case .targetBelief:
            if !confirmedTargetBelief.isEmpty {
                formulation = FormulationBuilder.setAppraisal(
                    in: formulation,
                    targetBelief: confirmedTargetBelief
                )
            }
            populateAvailableInterventions()
            navigationPath.append(.interventionSelection)

        case .interventionSelection:
            guard !selectedInterventions.isEmpty else {
                logger.warning("Cannot advance: no interventions selected", correlationID: correlationID)
                return
            }
            navigationPath.append(.experimentDesign)

        case .experimentDesign:
            navigationPath.append(.captureFields)

        case .captureFields:
            navigationPath.append(.standardisedMeasures)

        case .standardisedMeasures:
            navigationPath.append(.reviewRules)

        case .reviewRules:
            navigationPath.append(.generation)

        case .generation:
            break // Handled by generateProtocol()
        }
    }

    public func goBack() {
        guard !navigationPath.isEmpty else { return }
        logger.debug("Going back from stage: \(currentStage.title)", correlationID: correlationID)
        navigationPath.removeLast()
    }

    // MARK: - Guided Discovery: Opening Message

    /// Request the agent to send an opening message for the current guided discovery stage.
    /// Only sends if the stage conversation is empty.
    public func requestOpeningMessage() async {
        let stage = currentStage
        guard stage.isGuidedDiscovery else { return }
        guard (stageConversations[stage] ?? []).isEmpty else { return }

        isAgentTyping = true
        let prompt = WorkshopPrompts.systemPrompt(for: stage, context: buildWorkshopContext())

        do {
            let response = try await agentService.sendMessage(
                "Begin the guided discovery for this stage.",
                conversationHistory: [],
                systemPrompt: prompt
            )
            var messages = stageConversations[stage] ?? []
            messages.append(ConversationMessage(role: .assistant, content: response))
            stageConversations[stage] = messages
            logger.debug("Agent sent opening message for stage: \(stage.title)", correlationID: correlationID)
        } catch {
            logger.error("Failed to get opening message for \(stage.title): \(error.localizedDescription)", correlationID: correlationID)
        }

        isAgentTyping = false
    }

    // MARK: - Guided Discovery: Send Message

    public func sendMessage() async {
        let input = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }

        // Safety scan on user input before sending to agent
        if let alert = safetySystem.scanText(input) {
            logger.info("Safety alert triggered in sendMessage: \(alert.kind.rawValue)", correlationID: correlationID)
            pendingSafetyAlert = alert
            return
        }

        let stage = currentStage
        userInput = ""

        // Append user message
        var messages = stageConversations[stage] ?? []
        messages.append(ConversationMessage(role: .user, content: input))
        stageConversations[stage] = messages

        // Get agent response
        isAgentTyping = true
        let prompt = WorkshopPrompts.systemPrompt(for: stage, context: buildWorkshopContext())

        do {
            let response = try await agentService.sendMessage(
                input,
                conversationHistory: messages,
                systemPrompt: prompt
            )
            var updatedMessages = stageConversations[stage] ?? []
            updatedMessages.append(ConversationMessage(role: .assistant, content: response))
            stageConversations[stage] = updatedMessages
            logger.debug("Agent responded for stage: \(stage.title)", correlationID: correlationID)
        } catch {
            logger.error("Agent error in stage \(stage.title): \(error.localizedDescription)", correlationID: correlationID)
            var updatedMessages = stageConversations[stage] ?? []
            updatedMessages.append(ConversationMessage(
                role: .assistant,
                content: "I'm sorry, I had trouble responding. Could you try again?"
            ))
            stageConversations[stage] = updatedMessages
        }

        isAgentTyping = false
    }

    // MARK: - Stage 5: Intervention Selection

    public func selectIntervention(_ template: InterventionTemplate) {
        guard !selectedInterventions.contains(where: { $0.id == template.id }) else { return }
        selectedInterventions.append(template)
        logger.debug("Selected intervention: \(template.name)", correlationID: correlationID)
    }

    public func deselectIntervention(_ template: InterventionTemplate) {
        selectedInterventions.removeAll { $0.id == template.id }
        logger.debug("Deselected intervention: \(template.name)", correlationID: correlationID)
    }

    // MARK: - Stage 9: Generate Protocol

    public func generateProtocol() async {
        logger.info("Starting protocol generation", correlationID: correlationID)
        generationState = .generating

        let context = buildGenerationContext()

        do {
            let result: AgentResult
            if isRevisionMode, let existing = existingProtocol {
                result = try await agentService.reviseProtocol(existing: existing, context: context)
            } else {
                result = try await agentService.generateProtocol(context: context)
            }

            switch result {
            case .success(let proto):
                logger.info("Protocol generated: \(proto.name)", correlationID: correlationID)
                try await protocolRepository.save(proto)
                generationState = .success(proto)

            case .repairFailed(let errors):
                let errorMsg = errors.joined(separator: "; ")
                logger.error("Generation repair failed: \(errorMsg)", correlationID: correlationID)
                generationState = .failed("Validation failed: \(errorMsg)")

            case .networkError(let msg):
                logger.error("Generation network error: \(msg)", correlationID: correlationID)
                generationState = .failed(msg)
            }
        } catch {
            logger.error("Generation threw: \(error.localizedDescription)", correlationID: correlationID)
            generationState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    private func buildWorkshopContext() -> WorkshopContext {
        WorkshopContext(
            situation: situation.isEmpty ? nil : situation,
            hotThought: hotThought.isEmpty ? nil : hotThought,
            emotion: selectedEmotion,
            urge: selectedUrge,
            emotionIntensity: emotionIntensity,
            maintainingBehaviours: identifiedBehaviours,
            targetBelief: confirmedTargetBelief.isEmpty ? nil : confirmedTargetBelief,
            selectedInterventionNames: selectedInterventions.map(\.name)
        )
    }

    private func buildGenerationContext() -> GenerationContext {
        // Collect all conversation messages across stages in order
        var allMessages: [ConversationMessage] = []
        for stage in WorkshopStage.allCases where stage.isGuidedDiscovery {
            if let messages = stageConversations[stage] {
                allMessages.append(contentsOf: messages)
            }
        }

        // Add structured data as a summary message
        let summary = buildStructuredSummary()
        allMessages.append(ConversationMessage(role: .user, content: summary))

        return GenerationContext(
            workshopMessages: allMessages,
            existingProtocol: existingProtocol
        )
    }

    private func buildStructuredSummary() -> String {
        var parts: [String] = []
        parts.append("WORKSHOP SUMMARY")
        parts.append("Situation: \(situation)")
        parts.append("Hot thought: \(hotThought)")
        if let emotion = selectedEmotion {
            parts.append("Emotion: \(emotion.displayName) (intensity: \(emotionIntensity))")
        }
        if let urge = selectedUrge {
            parts.append("Urge: \(urge.displayName)")
        }
        if !confirmedTargetBelief.isEmpty {
            parts.append("Target belief: \(confirmedTargetBelief)")
        }
        if !identifiedBehaviours.isEmpty {
            let behaviourNames = identifiedBehaviours.map(\.type.displayName)
            parts.append("Maintaining behaviours: \(behaviourNames.joined(separator: ", "))")
        }
        if !selectedInterventions.isEmpty {
            let names = selectedInterventions.map(\.name)
            parts.append("Selected interventions: \(names.joined(separator: ", "))")
        }
        if !experimentPrediction.isEmpty {
            parts.append("Experiment prediction: \(experimentPrediction)")
            parts.append("Experiment steps: \(experimentSteps.filter { !$0.isEmpty }.joined(separator: "; "))")
            parts.append("Success criteria: \(experimentSuccessCriteria)")
        }
        let fieldNames = captureFields.map(\.fieldType.rawValue)
        parts.append("Capture fields: \(fieldNames.joined(separator: ", "))")
        if !selectedMeasures.isEmpty {
            parts.append("Standardised measures: \(selectedMeasures.map(\.measureID).joined(separator: ", "))")
        }
        parts.append("Review rules: \(reviewRules.map { "\($0.condition) → \($0.action)" }.joined(separator: "; "))")
        return parts.joined(separator: "\n")
    }

    private func populateAvailableInterventions() {
        var keywords: [String] = []
        if let emotion = selectedEmotion {
            keywords.append(emotion.displayName.lowercased())
        }
        if let urge = selectedUrge {
            keywords.append(urge.displayName.lowercased())
        }

        let query = InterventionSelector.Query(indicationKeywords: keywords)
        availableInterventions = InterventionSelector.select(query: query)
        logger.debug("Populated \(availableInterventions.count) available interventions", correlationID: correlationID)
    }
}
