import Foundation

/// Input state for JITAI decision logic.
public struct JITAIState: Sendable {
    public var currentTime: Date
    public var lastRunTime: Date?
    public var lastRunIntensity: Double?
    public var capturedIntensity: Double?
    public var capturedHotThought: String?
    public var capturedSituation: String?
    public var capturedUrge: UrgeType?
    public var hasActiveExperiment: Bool
    public var hasDueMeasure: Bool
    public var completedRunCount: Int

    public init(
        currentTime: Date = Date(),
        lastRunTime: Date? = nil,
        lastRunIntensity: Double? = nil,
        capturedIntensity: Double? = nil,
        capturedHotThought: String? = nil,
        capturedSituation: String? = nil,
        capturedUrge: UrgeType? = nil,
        hasActiveExperiment: Bool = false,
        hasDueMeasure: Bool = false,
        completedRunCount: Int = 0
    ) {
        self.currentTime = currentTime
        self.lastRunTime = lastRunTime
        self.lastRunIntensity = lastRunIntensity
        self.capturedIntensity = capturedIntensity
        self.capturedHotThought = capturedHotThought
        self.capturedSituation = capturedSituation
        self.capturedUrge = capturedUrge
        self.hasActiveExperiment = hasActiveExperiment
        self.hasDueMeasure = hasDueMeasure
        self.completedRunCount = completedRunCount
    }
}

/// Output of JITAI evaluation — guidance for intervention selection.
public struct JITAIGuidance: Sendable, Equatable {
    public var suggestedAction: SuggestedAction?
    public var preferredTypes: Set<InterventionType>?
    public var indicationKeywords: [String]
    public var contraindicationExclusions: [String]
    public var reasoning: String

    public init(
        suggestedAction: SuggestedAction? = nil,
        preferredTypes: Set<InterventionType>? = nil,
        indicationKeywords: [String] = [],
        contraindicationExclusions: [String] = [],
        reasoning: String = ""
    ) {
        self.suggestedAction = suggestedAction
        self.preferredTypes = preferredTypes
        self.indicationKeywords = indicationKeywords
        self.contraindicationExclusions = contraindicationExclusions
        self.reasoning = reasoning
    }
}

/// Just-In-Time Adaptive Intervention decision engine.
///
/// Evaluates contextual rules in priority order to determine
/// what intervention or action to recommend.
public enum JITAIEngine {

    /// Evaluate all JITAI rules and return guidance.
    /// Rules are checked in priority order — first match wins for actions.
    public static func evaluate(
        state: JITAIState,
        protocol cbtProtocol: CBTProtocol
    ) -> JITAIGuidance {
        // Priority 1: Standardised measure due
        if state.hasDueMeasure {
            return JITAIGuidance(
                suggestedAction: SuggestedAction(
                    type: .promptMeasure,
                    message: "A standardised measure is due. Complete it before starting the intervention."
                ),
                reasoning: "Measure due — prompt before intervention"
            )
        }

        // Priority 2: Active experiment follow-up
        if state.hasActiveExperiment {
            return JITAIGuidance(
                suggestedAction: SuggestedAction(
                    type: .followUpExperiment,
                    message: "You have an active experiment. Would you like to record the outcome?"
                ),
                reasoning: "Active experiment detected — prompt follow-up"
            )
        }

        // Priority 3: Recent run with low intensity → suggest outside-app action
        if let lastRunTime = state.lastRunTime,
           let lastIntensity = state.lastRunIntensity {
            let hoursSinceLastRun = state.currentTime.timeIntervalSince(lastRunTime) / 3600
            if hoursSinceLastRun < 2 && lastIntensity < 30 {
                return JITAIGuidance(
                    suggestedAction: SuggestedAction(
                        type: .outsideAppAction,
                        message: "You completed a run recently and your intensity was low. Consider trying your forward plan outside the app."
                    ),
                    reasoning: "Recent run (<2h) with low intensity (<30) — suggest outside-app action"
                )
            }
        }

        // Priority 4: First-ever run — default to behavioural experiment
        if state.completedRunCount == 0 {
            return JITAIGuidance(
                preferredTypes: [.behaviouralExperiment],
                indicationKeywords: ["prediction", "testable"],
                reasoning: "First run — default to behavioural experiment"
            )
        }

        // Priority 5: Urge-based intervention selection
        if let urge = state.capturedUrge {
            return urgeBasedGuidance(urge: urge, state: state)
        }

        // Priority 6: Intensity-based intervention selection
        if let intensity = state.capturedIntensity {
            return intensityBasedGuidance(intensity: intensity, state: state)
        }

        // Default: no specific guidance, let selector use full library
        return JITAIGuidance(reasoning: "No specific JITAI rule matched — using default selection")
    }

    // MARK: - Urge-based logic

    private static func urgeBasedGuidance(urge: UrgeType, state: JITAIState) -> JITAIGuidance {
        switch urge {
        case .ruminate:
            return JITAIGuidance(
                preferredTypes: [.ruminationScheduling, .defusion],
                indicationKeywords: ["ruminat", "worries", "repetitive"],
                reasoning: "Urge to ruminate — suggest rumination scheduling or defusion"
            )
        case .avoid:
            return JITAIGuidance(
                preferredTypes: [.gradedExposureStep, .behaviouralExperiment],
                indicationKeywords: ["avoid", "approach"],
                reasoning: "Urge to avoid — suggest graded exposure or behavioural experiment"
            )
        case .check, .reassuranceSeek:
            return JITAIGuidance(
                preferredTypes: [.delayExperiment, .behaviouralExperiment],
                indicationKeywords: ["urge", "checking", "reassurance"],
                reasoning: "Urge to check/seek reassurance — suggest delay experiment"
            )
        case .withdraw:
            return JITAIGuidance(
                preferredTypes: [.oppositeAction, .behaviouralActivation],
                indicationKeywords: ["withdraw", "low mood"],
                reasoning: "Urge to withdraw — suggest opposite action or behavioural activation"
            )
        case .scroll, .distract:
            return JITAIGuidance(
                preferredTypes: [.delayExperiment, .oppositeAction],
                indicationKeywords: ["urge", "distract"],
                reasoning: "Urge to scroll/distract — suggest delay experiment"
            )
        case .overwork:
            return JITAIGuidance(
                preferredTypes: [.behaviouralExperiment, .problemSolvingStep],
                indicationKeywords: ["perfectionism", "overwork"],
                reasoning: "Urge to overwork — suggest behavioural experiment"
            )
        case .argue, .selfCriticise:
            return JITAIGuidance(
                preferredTypes: [.defusion, .oppositeAction],
                indicationKeywords: ["repetitive", "self-critic"],
                reasoning: "Urge to argue/self-criticise — suggest defusion"
            )
        case .binge:
            return JITAIGuidance(
                preferredTypes: [.delayExperiment, .oppositeAction],
                indicationKeywords: ["urge"],
                reasoning: "Urge to binge — suggest delay experiment"
            )
        }
    }

    // MARK: - Intensity-based logic

    private static func intensityBasedGuidance(intensity: Double, state: JITAIState) -> JITAIGuidance {
        switch intensity {
        case 0..<30:
            // Low intensity — good time for behavioural experiments
            return JITAIGuidance(
                preferredTypes: [.behaviouralExperiment, .behaviouralActivation],
                indicationKeywords: ["prediction", "activity"],
                reasoning: "Low intensity (<30) — good window for behavioural experiment"
            )
        case 30..<60:
            // Moderate — standard intervention selection
            return JITAIGuidance(
                indicationKeywords: ["prediction"],
                reasoning: "Moderate intensity (30-60) — standard selection"
            )
        case 60..<80:
            // High — consider grounding or delay
            return JITAIGuidance(
                preferredTypes: [.delayExperiment, .defusion, .oppositeAction],
                indicationKeywords: ["urge", "repetitive"],
                contraindicationExclusions: ["acute distress"],
                reasoning: "High intensity (60-80) — suggest delay or defusion"
            )
        default:
            // Very high — prioritise delay and simple steps
            return JITAIGuidance(
                preferredTypes: [.delayExperiment],
                indicationKeywords: ["urge"],
                contraindicationExclusions: ["acute distress", "acute crisis"],
                reasoning: "Very high intensity (80+) — prioritise delay experiment"
            )
        }
    }
}
