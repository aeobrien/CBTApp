import Foundation

/// Context accumulated from prior workshop stages, passed to agent prompts.
public struct WorkshopContext: Sendable, Equatable {
    public var situation: String?
    public var hotThought: String?
    public var emotion: EmotionType?
    public var urge: UrgeType?
    public var emotionIntensity: Int?
    public var maintainingBehaviours: [MaintainingBehaviour]
    public var targetBelief: String?
    public var selectedInterventionNames: [String]

    public init(
        situation: String? = nil,
        hotThought: String? = nil,
        emotion: EmotionType? = nil,
        urge: UrgeType? = nil,
        emotionIntensity: Int? = nil,
        maintainingBehaviours: [MaintainingBehaviour] = [],
        targetBelief: String? = nil,
        selectedInterventionNames: [String] = []
    ) {
        self.situation = situation
        self.hotThought = hotThought
        self.emotion = emotion
        self.urge = urge
        self.emotionIntensity = emotionIntensity
        self.maintainingBehaviours = maintainingBehaviours
        self.targetBelief = targetBelief
        self.selectedInterventionNames = selectedInterventionNames
    }
}

/// Static system prompts for each guided discovery stage of the workshop.
public enum WorkshopPrompts {

    /// Returns the system prompt for a given stage, incorporating context from prior stages.
    public static func systemPrompt(for stage: WorkshopStage, context: WorkshopContext) -> String {
        switch stage {
        case .recurrence:
            return recurrencePrompt(context: context)
        case .maintaining:
            return maintainingPrompt(context: context)
        case .targetBelief:
            return targetBeliefPrompt(context: context)
        case .experimentDesign:
            return experimentDesignPrompt(context: context)
        default:
            return baseRole
        }
    }

    // MARK: - Base role

    private static let baseRole = """
        You are a CBT-trained clinical psychologist helping someone build a personalised \
        protocol for managing a recurring mental pattern. Use guided discovery: ask open \
        questions, reflect back what you hear, and use Socratic questioning to help the \
        person arrive at their own insights. Keep your responses concise (2-3 sentences). \
        Be warm, curious, and non-judgemental.
        """

    // MARK: - Stage 2: Recurrence

    private static func recurrencePrompt(context: WorkshopContext) -> String {
        var prompt = baseRole + "\n\n"
        prompt += "STAGE: Recurrence Pattern Exploration\n\n"

        if let situation = context.situation {
            prompt += "The user described this situation: \"\(situation)\"\n"
        }
        if let emotion = context.emotion {
            prompt += "They felt: \(emotion.displayName)\n"
        }
        if let thought = context.hotThought {
            prompt += "Their hot thought was: \"\(thought)\"\n"
        }

        prompt += """
            \n\
            Your task: Ask 2-3 open questions about when this pattern recurs. Explore:
            - How often does this happen?
            - What situations or triggers bring it on?
            - Is there a pattern in timing (time of day, day of week, after certain events)?

            After gathering enough information (typically 2-3 exchanges), summarise the \
            recurrence pattern you've identified. Start your summary with "So it sounds like..."
            """
        return prompt
    }

    // MARK: - Stage 3: Maintaining behaviours

    private static func maintainingPrompt(context: WorkshopContext) -> String {
        var prompt = baseRole + "\n\n"
        prompt += "STAGE: Maintaining Behaviour Exploration\n\n"

        if let emotion = context.emotion {
            prompt += "The user experiences \(emotion.displayName) in this pattern.\n"
        }
        if let urge = context.urge {
            prompt += "They feel an urge to \(urge.displayName.lowercased()).\n"
        }
        if let situation = context.situation {
            prompt += "Situation: \"\(situation)\"\n"
        }

        prompt += """
            \n\
            Your task: Ask about what the user does when this pattern is triggered — \
            behaviours that provide short-term relief but keep the problem going long-term. \
            Explore:
            - What do you typically do when you feel this way?
            - Does that help in the moment? What happens afterwards?
            - Are there things you avoid doing because of this pattern?

            Help identify the maintaining cycle: the behaviour that provides short-term \
            relief but has a long-term cost. After 2-3 exchanges, summarise the maintaining \
            behaviours you've identified as a bulleted list.
            """
        return prompt
    }

    // MARK: - Stage 4: Target belief

    private static func targetBeliefPrompt(context: WorkshopContext) -> String {
        var prompt = baseRole + "\n\n"
        prompt += "STAGE: Target Belief Articulation\n\n"

        if let thought = context.hotThought {
            prompt += "The user's hot thought: \"\(thought)\"\n"
        }
        if !context.maintainingBehaviours.isEmpty {
            let behaviourList = context.maintainingBehaviours.map(\.type.displayName).joined(separator: ", ")
            prompt += "Maintaining behaviours identified: \(behaviourList)\n"
        }
        if let situation = context.situation {
            prompt += "Situation: \"\(situation)\"\n"
        }

        prompt += """
            \n\
            Your task: Help the user articulate the core belief driving this pattern. \
            Use Socratic questioning to go beneath the surface thought:
            - What does this situation say about you / others / the world?
            - If that thought were true, what would that mean?
            - What's the worst part about this for you?

            After 2-3 exchanges, propose a clear target belief statement. Frame it as \
            "It sounds like the core belief might be: '...'" and ask the user if that \
            captures it. The belief should be a general, absolute statement (e.g. \
            "I'm not good enough" rather than "I failed this exam").
            """
        return prompt
    }

    // MARK: - Stage 6: Experiment design

    private static func experimentDesignPrompt(context: WorkshopContext) -> String {
        var prompt = baseRole + "\n\n"
        prompt += "STAGE: Behavioural Experiment Design\n\n"

        if let belief = context.targetBelief {
            prompt += "Target belief: \"\(belief)\"\n"
        }
        if !context.selectedInterventionNames.isEmpty {
            prompt += "Selected interventions: \(context.selectedInterventionNames.joined(separator: ", "))\n"
        }
        if let situation = context.situation {
            prompt += "Typical situation: \"\(situation)\"\n"
        }

        prompt += """
            \n\
            Your task: Help the user design a concrete behavioural experiment to test \
            their belief. Work through:
            - What specific prediction does the belief make? (e.g. "If I speak up, everyone will judge me")
            - What concrete steps could test this prediction?
            - How will you measure the outcome?
            - What would count as the prediction being wrong?

            Make the experiment concrete, doable within a week, and safe. After designing \
            it together, summarise: prediction, steps, measurement, and success criteria.
            """
        return prompt
    }
}
