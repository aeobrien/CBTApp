import Foundation

/// The protocol engine loads a CBTProtocol and drives run-time decisions.
///
/// It provides the ordered capture fields, recommends interventions
/// via JITAI logic, and evaluates review/escalation rules.
public struct ProtocolEngine: Sendable {

    public let cbtProtocol: CBTProtocol

    public init(cbtProtocol: CBTProtocol) {
        self.cbtProtocol = cbtProtocol
    }

    // MARK: - Capture Fields

    /// Returns capture fields in the protocol-specified order.
    public var orderedCaptureFields: [CaptureField] {
        cbtProtocol.captureFields
    }

    // MARK: - Intervention Recommendation

    /// Recommend an intervention based on the current run state and history.
    public func recommendIntervention(
        state: JITAIState
    ) -> InterventionRecommendation {
        let jitai = JITAIEngine.evaluate(state: state, protocol: cbtProtocol)

        // If JITAI suggests a specific action instead of an intervention, return that
        if let action = jitai.suggestedAction {
            return .action(action)
        }

        // Build selection query from JITAI guidance
        let query = InterventionSelector.Query(
            types: jitai.preferredTypes,
            indicationKeywords: jitai.indicationKeywords,
            excludeContraindications: jitai.contraindicationExclusions,
            applyACTBoundary: true
        )

        let candidates = InterventionSelector.select(query: query)

        guard let best = candidates.first else {
            // Fallback: use the protocol's own interventions
            if let fallback = cbtProtocol.interventions.first {
                return .intervention(fallback)
            }
            return .action(.init(
                type: .noInterventionAvailable,
                message: "No suitable intervention found for the current state."
            ))
        }

        // Parameterise the template
        let context = InterventionParameteriser.Context(
            hotThought: state.capturedHotThought,
            prediction: state.capturedPrediction,
            targetBelief: cbtProtocol.targets.targetBelief,
            targetSituation: state.capturedSituation,
            urgeBehaviour: state.capturedUrge?.displayName
        )
        let instance = InterventionParameteriser.parameterise(template: best, context: context)
        return .intervention(instance)
    }

    // MARK: - Review Rules

    /// Evaluate review rules against run history.
    public func evaluateReviewRules(
        completedRunCount: Int,
        recentEmotionChanges: [Double]
    ) -> [ReviewRuleResult] {
        ReviewRuleEvaluator.evaluate(
            rules: cbtProtocol.reviewRules,
            completedRunCount: completedRunCount,
            recentEmotionChanges: recentEmotionChanges
        )
    }

    // MARK: - Measure Checks

    /// Returns any standardised measures that are due for administration.
    public var dueMeasures: [StandardisedMeasure] {
        cbtProtocol.standardisedMeasures.filter { $0.isDue() }
    }

    // MARK: - Protocol Version

    /// The version string to stamp on runs created with this engine.
    public var protocolVersion: String {
        cbtProtocol.version
    }
}

// MARK: - Recommendation Result

/// The result of an intervention recommendation.
public enum InterventionRecommendation: Sendable, Equatable {
    case intervention(InterventionInstance)
    case action(SuggestedAction)
}

/// A non-intervention action suggested by the engine.
public struct SuggestedAction: Sendable, Equatable {
    public var type: ActionType
    public var message: String

    public init(type: ActionType, message: String) {
        self.type = type
        self.message = message
    }

    public enum ActionType: String, Sendable, Equatable {
        case outsideAppAction
        case followUpExperiment
        case promptMeasure
        case noInterventionAvailable
    }
}
