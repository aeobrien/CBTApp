import Foundation

/// Configurable mock for AgentServiceProtocol, for testing and previews.
public final class MockAgentService: AgentServiceProtocol, @unchecked Sendable {

    // MARK: - Configuration

    /// Result to return from `sendMessage`. Defaults to a canned response.
    public var sendMessageResult: Result<String, Error> = .success("Mock agent response")

    /// When true, returns stage-appropriate contextual responses instead of the static `sendMessageResult`.
    public var useContextualResponses: Bool = false

    /// Result to return from `generateProtocol`.
    public var generateResult: Result<AgentResult, Error>

    /// Result to return from `reviseProtocol`.
    public var reviseResult: Result<AgentResult, Error>

    // MARK: - Call tracking

    public private(set) var sendMessageCallCount = 0
    public private(set) var generateCallCount = 0
    public private(set) var reviseCallCount = 0
    public private(set) var lastGenerationContext: GenerationContext?
    public private(set) var lastRevisionProtocol: CBTProtocol?

    // MARK: - Init

    public init(
        generateResult: Result<AgentResult, Error> = .success(.success(MockAgentService.richMockProtocol)),
        reviseResult: Result<AgentResult, Error> = .success(.success(MockAgentService.richMockProtocol))
    ) {
        self.generateResult = generateResult
        self.reviseResult = reviseResult
    }

    /// A mock protocol with realistic interventions and experiments.
    public static let richMockProtocol = CBTProtocol(
        name: "Presentation Anxiety Protocol",
        summary: "A personalised protocol for managing anxiety around work presentations and social evaluation.",
        whenToUse: ["Before a meeting or presentation", "When anticipating being judged"],
        hotThoughtTemplates: ["I'm going to mess this up", "Everyone will judge me"],
        maintainingBehaviours: [
            MaintainingBehaviour(type: .avoidance, shortTermRelief: "Temporary relief from anxiety", longTermCost: "Missed opportunities, fear grows"),
            MaintainingBehaviour(type: .overworking, shortTermRelief: "Feels productive and safe", longTermCost: "Reinforces belief you can't cope naturally")
        ],
        targets: ProtocolTargets(targetBelief: "I'm not competent enough and people will judge me", targetLoop: .avoidance),
        interventions: [
            InterventionInstance(
                interventionID: "be_01",
                type: .behaviouralExperiment,
                title: "Speak up with minimal prep",
                script: "Raise one point in a meeting with no more than 2 minutes of preparation. Note what actually happens.",
                durationEstimate: 60
            ),
            InterventionInstance(
                interventionID: "defusion_01",
                type: .defusion,
                title: "Thought labelling",
                script: "Notice the thought. Say to yourself: 'I'm having the thought that I'll mess up.' Observe it without buying in.",
                durationEstimate: 30
            )
        ],
        experiments: [
            Experiment(
                prediction: "If I contribute without extensive preparation, people will think I'm incompetent",
                steps: ["Choose a low-stakes meeting", "Prepare for max 2 minutes", "Raise one point", "Note reactions"],
                measures: ["People's actual reactions", "Anxiety level before/after (0-100)"],
                successCriteria: "At least one person responds neutrally or positively"
            )
        ],
        tags: ["anxiety", "work", "presentation"]
    )

    // MARK: - AgentServiceProtocol

    public func sendMessage(
        _ message: String,
        conversationHistory: [ConversationMessage],
        systemPrompt: String
    ) async throws -> String {
        sendMessageCallCount += 1

        if useContextualResponses {
            return contextualResponse(
                for: systemPrompt,
                exchangeCount: conversationHistory.filter { $0.role == .user }.count
            )
        }

        return try sendMessageResult.get()
    }

    public func generateProtocol(context: GenerationContext) async throws -> AgentResult {
        generateCallCount += 1
        lastGenerationContext = context
        return try generateResult.get()
    }

    public func reviseProtocol(
        existing: CBTProtocol,
        context: GenerationContext
    ) async throws -> AgentResult {
        reviseCallCount += 1
        lastRevisionProtocol = existing
        return try reviseResult.get()
    }

    // MARK: - Contextual Responses

    private func contextualResponse(for systemPrompt: String, exchangeCount: Int) -> String {
        // Order matters: check more specific strings first. Stage 4's prompt
        // also contains "Maintaining" in context, so "Target Belief" must come first.
        if systemPrompt.contains("Target Belief") {
            return targetBeliefResponses[min(exchangeCount, targetBeliefResponses.count - 1)]
        } else if systemPrompt.contains("Experiment") {
            return experimentResponses[min(exchangeCount, experimentResponses.count - 1)]
        } else if systemPrompt.contains("Maintaining") {
            return maintainingResponses[min(exchangeCount, maintainingResponses.count - 1)]
        } else if systemPrompt.contains("Recurrence") {
            return recurrenceResponses[min(exchangeCount, recurrenceResponses.count - 1)]
        }
        return "Tell me more about that. What stands out to you most?"
    }

    private let recurrenceResponses = [
        "That sounds like a difficult situation. Can you tell me — how often does this kind of thing come up for you? Is it mostly at work, or does it happen in other areas too?",
        "I see, so it's a recurring pattern. When you think about the last few times this happened, is there anything they had in common? A particular time of day, or a certain type of situation?",
        "So it sounds like this pattern tends to show up when you're facing situations where you feel you might be evaluated or judged, and it happens fairly regularly — perhaps a few times a week. The anticipation seems to be a big part of it. Does that capture it?"
    ]

    private let maintainingResponses = [
        "When you notice that anxiety building before a situation like this, what do you typically do? For example, do you find yourself preparing excessively, avoiding, or perhaps seeking reassurance from others?",
        "That makes sense — those behaviours probably help in the moment. But what happens afterwards? Do they tend to make the pattern better or worse in the long run?",
        "So it sounds like the main maintaining behaviours are:\n\n- **Avoidance** — short-term relief from anxiety, but long-term you miss opportunities and the fear grows\n- **Over-preparation** — feels productive but reinforces the belief that you can't handle things naturally\n\nDoes that capture the cycle?"
    ]

    private let targetBeliefResponses = [
        "Let's dig into what's underneath that thought. When you imagine messing up in front of people — what would that mean about you? What's the worst part of that scenario?",
        "And if people did judge you negatively, what would that say about you as a person? I'm trying to get at the deeper belief here.",
        "It sounds like the core belief might be: \"I'm not competent enough, and if people see the real me, they'll judge me.\" Does that feel like it captures the pattern? Feel free to adjust the wording until it feels right."
    ]

    private let experimentResponses = [
        "Let's design an experiment to test this belief. What specific prediction does it make? For instance, if you were to speak up in a meeting without over-preparing, what exactly do you predict would happen?",
        "Good — that's a testable prediction. Now, what would be a small, manageable way to test it this week? Something that feels a bit uncomfortable but not overwhelming.",
        "Great, let's structure this:\n\n- **Prediction**: \"If I contribute without extensive preparation, people will think I'm incompetent\"\n- **Test**: Raise one point in a meeting this week with minimal preparation\n- **Measure**: Note people's actual reactions and compare to your prediction\n- **Success criteria**: At least one person responds neutrally or positively\n\nDoes that feel doable?"
    ]
}
