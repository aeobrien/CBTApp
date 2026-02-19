import Foundation

/// The curated library of evidence-based intervention templates.
///
/// This is the single source of truth for all interventions the system
/// can recommend. The agent selects from this library — it does not
/// invent new intervention types.
public enum InterventionLibrary {

    /// All templates in the library.
    public static let allTemplates: [InterventionTemplate] = [
        // Behavioural Experiments
        behaviouralExperimentPredictionTest,
        behaviouralExperimentSurvey,
        // Defusion
        defusionThoughtLabelling,
        // Graded Exposure
        gradedExposureStep,
        // Behavioural Activation
        behaviouralActivationScheduling,
        // Delay Experiment
        delayExperimentUrge,
        // Opposite Action
        oppositeActionWithdrawal,
        // Rumination Scheduling
        ruminationSchedulingWorryTime,
        // Problem Solving
        problemSolvingStep,
    ]

    // MARK: - Behavioural Experiments

    public static let behaviouralExperimentPredictionTest = InterventionTemplate(
        id: "be-prediction-test",
        type: .behaviouralExperiment,
        name: "Prediction Test",
        indication: "Client holds a specific testable prediction about what will happen in a situation",
        contraindications: [
            "Prediction involves genuine danger",
            "Client is in acute crisis",
            "Situation would require someone else's cooperation that can't be arranged"
        ],
        steps: [
            "Write down the specific prediction (what exactly will happen?)",
            "Rate how strongly you believe it (0-100%)",
            "Identify what you'll actually do to test it",
            "Carry out the test",
            "Record what actually happened",
            "Compare the outcome to your prediction",
            "Re-rate your belief strength"
        ],
        exampleScripts: [
            "You predicted that {{hotThought}}. Let's test this — what would you need to do to find out if this is actually true?",
            "Before we test this, write down exactly what you think will happen. Be as specific as you can — this helps us compare later."
        ],
        durationEstimate: 600,
        successCriteria: "Client completes the experiment and compares outcome to prediction, regardless of result",
        evidenceBasis: "Bennett-Levy et al. (2004) Oxford Guide to Behavioural Experiments in Cognitive Therapy"
    )

    public static let behaviouralExperimentSurvey = InterventionTemplate(
        id: "be-survey",
        type: .behaviouralExperiment,
        name: "Survey Experiment",
        indication: "Client believes their experience or reaction is abnormal or unique",
        contraindications: [
            "Client has social anxiety that would make surveying distressing",
            "The belief involves private/sensitive topics others wouldn't discuss"
        ],
        steps: [
            "Identify the specific belief to test (e.g. 'Nobody else feels this way')",
            "Decide who to ask and what question to pose",
            "Ask 2-3 trusted people",
            "Record their responses",
            "Compare responses to your original belief"
        ],
        exampleScripts: [
            "You believe that {{hotThought}}. One way to check is to ask people you trust — what do you think you'd find out?",
            "Sometimes we assume we're the only ones who feel a certain way. Let's design a small survey to test that assumption."
        ],
        durationEstimate: 300,
        successCriteria: "Client gathers at least 2 data points and reflects on what they learned",
        evidenceBasis: "Bennett-Levy et al. (2004) Oxford Guide to Behavioural Experiments in Cognitive Therapy"
    )

    // MARK: - Defusion

    public static let defusionThoughtLabelling = InterventionTemplate(
        id: "defusion-thought-labelling",
        type: .defusion,
        name: "Thought Labelling",
        indication: "Client is fused with a repetitive thought and treating it as literal truth. Use only when a behavioural experiment is not feasible for this thought.",
        contraindications: [
            "A behavioural experiment would be more appropriate and feasible",
            "Client is in acute distress requiring grounding first",
            "Client has not been introduced to the concept of cognitive defusion"
        ],
        steps: [
            "Notice the thought that keeps showing up",
            "Say to yourself: 'I notice I'm having the thought that...'",
            "Repeat the thought with this prefix 3 times",
            "Notice any shift in how the thought feels",
            "Optionally try: 'My mind is telling me that...'"
        ],
        exampleScripts: [
            "The thought '{{hotThought}}' keeps coming back. Instead of arguing with it, try saying: 'I notice I'm having the thought that {{hotThought}}.'",
            "This isn't about whether the thought is true or false — it's about creating a bit of distance so it has less pull on you."
        ],
        durationEstimate: 180,
        successCriteria: "Client reports even a small shift in how 'stuck' the thought feels",
        evidenceBasis: "Hayes et al. (2012) Acceptance and Commitment Therapy. ACT-bounded: use only when behavioural experiment not feasible."
    )

    // MARK: - Graded Exposure

    public static let gradedExposureStep = InterventionTemplate(
        id: "graded-exposure-step",
        type: .gradedExposureStep,
        name: "Graded Exposure Step",
        indication: "Client is avoiding a specific situation and wants to gradually approach it",
        contraindications: [
            "Avoidance is of a genuinely dangerous situation",
            "Client has not agreed to an exposure hierarchy",
            "Client is in acute crisis"
        ],
        steps: [
            "Review your exposure hierarchy and identify the next step",
            "Rate your anticipated anxiety (0-100)",
            "Approach the situation as planned",
            "Stay in the situation until anxiety reduces by at least half",
            "Rate your actual anxiety at peak and at end",
            "Record what you learned"
        ],
        exampleScripts: [
            "The next step on your ladder is {{targetSituation}}. Before you begin, how anxious do you expect to feel (0-100)?",
            "Remember: the goal isn't to feel no anxiety — it's to learn that you can handle it and that it comes down on its own."
        ],
        durationEstimate: 900,
        successCriteria: "Client approaches the situation and remains until anxiety reduces noticeably",
        evidenceBasis: "Craske et al. (2014) Maximizing exposure therapy: An inhibitory learning approach"
    )

    // MARK: - Behavioural Activation

    public static let behaviouralActivationScheduling = InterventionTemplate(
        id: "ba-scheduling",
        type: .behaviouralActivation,
        name: "Activity Scheduling",
        indication: "Client is withdrawing from activities and experiencing low mood or anhedonia",
        contraindications: [
            "Client is too fatigued for any activity (consider micro-activation instead)",
            "Proposed activity relies on another person who is unavailable"
        ],
        steps: [
            "Identify one small activity you've been avoiding",
            "Rate how much pleasure/mastery you expect (0-10)",
            "Schedule a specific time and place",
            "Do the activity",
            "Rate actual pleasure/mastery afterwards",
            "Compare expected vs actual ratings"
        ],
        exampleScripts: [
            "When we're low, we often stop doing things that help us feel better. Let's pick one small thing and schedule it in.",
            "It doesn't have to be big — even a 10-minute walk counts. What's one thing you used to enjoy or feel good at?"
        ],
        durationEstimate: 300,
        successCriteria: "Client schedules and completes one activity, comparing expected to actual enjoyment",
        evidenceBasis: "Martell et al. (2010) Behavioral Activation for Depression"
    )

    // MARK: - Delay Experiment

    public static let delayExperimentUrge = InterventionTemplate(
        id: "delay-experiment-urge",
        type: .delayExperiment,
        name: "Urge Delay",
        indication: "Client experiences a strong urge to engage in a maintaining behaviour (e.g. checking, scrolling, reassurance-seeking)",
        contraindications: [
            "Urge is related to self-harm (use safety protocol instead)",
            "Client has not identified the urge as a target"
        ],
        steps: [
            "Notice the urge and rate its intensity (0-100)",
            "Set a timer for 10 minutes",
            "During the delay, observe the urge without acting on it",
            "After the timer, re-rate the urge intensity",
            "Decide whether to act on it or extend the delay",
            "Record what happened to the urge over time"
        ],
        exampleScripts: [
            "You're feeling the urge to {{urgeBehaviour}}. Instead of acting on it right now, let's wait 10 minutes and see what happens to the urge.",
            "Urges are like waves — they rise, peak, and fall. Let's ride this one out and see."
        ],
        durationEstimate: 600,
        successCriteria: "Client delays acting on urge for at least 10 minutes and observes intensity change",
        evidenceBasis: "Marlatt & Gordon (1985) Relapse Prevention; urge surfing technique"
    )

    // MARK: - Opposite Action

    public static let oppositeActionWithdrawal = InterventionTemplate(
        id: "opposite-action-withdrawal",
        type: .oppositeAction,
        name: "Opposite Action",
        indication: "Client's emotion is driving a behaviour that maintains the problem (e.g. withdrawing when sad, avoiding when anxious)",
        contraindications: [
            "The emotion-driven action is genuinely protective",
            "Client is too distressed to engage with the exercise"
        ],
        steps: [
            "Identify the emotion and the action it's pushing you towards",
            "Identify what the opposite action would be",
            "Act opposite to the emotional urge, fully and completely",
            "Notice how the emotion changes afterwards",
            "Record what you learned"
        ],
        exampleScripts: [
            "Your mood is pushing you to withdraw and stay in bed. The opposite action would be to get up and do something — even something small. What could that be?",
            "Opposite action isn't about forcing yourself to feel different — it's about breaking the loop between the emotion and the behaviour that keeps it going."
        ],
        durationEstimate: 300,
        successCriteria: "Client identifies and carries out the opposite action, noting any emotional shift",
        evidenceBasis: "Linehan (2015) DBT Skills Training Manual — opposite action for emotion regulation"
    )

    // MARK: - Rumination Scheduling

    public static let ruminationSchedulingWorryTime = InterventionTemplate(
        id: "rumination-scheduling-worry-time",
        type: .ruminationScheduling,
        name: "Worry Time",
        indication: "Client ruminates or worries throughout the day, unable to disengage",
        contraindications: [
            "Client is in acute crisis",
            "Rumination content involves active suicidal ideation (use safety protocol)"
        ],
        steps: [
            "Choose a 15-minute 'worry time' slot for tomorrow",
            "When a worry arises outside this time, jot it down briefly",
            "Tell yourself: 'I'll think about this during worry time'",
            "During worry time, review your list and think through each item",
            "When the 15 minutes end, stop and move to another activity",
            "Notice whether the worries feel different when you return to them"
        ],
        exampleScripts: [
            "Instead of trying to stop worrying entirely, let's give your worries a scheduled slot. When would work for a 15-minute worry time tomorrow?",
            "The idea is that postponing — not suppressing — the worry gives you more control over when you engage with it."
        ],
        durationEstimate: 900,
        successCriteria: "Client postpones worries to scheduled time for at least one day and reflects on the experience",
        evidenceBasis: "Borkovec et al. (1983) Stimulus control treatment for worry; Wells (2009) Metacognitive Therapy"
    )

    // MARK: - Problem Solving

    public static let problemSolvingStep = InterventionTemplate(
        id: "problem-solving-step",
        type: .problemSolvingStep,
        name: "Problem-Solving Step",
        indication: "Client faces a concrete, solvable problem but feels stuck or overwhelmed",
        contraindications: [
            "The 'problem' is actually an uncontrollable worry (use rumination scheduling instead)",
            "Client is too distressed to think through options"
        ],
        steps: [
            "Define the problem in one sentence",
            "Brainstorm 3-5 possible solutions (don't judge yet)",
            "Rate each solution on feasibility and likely effectiveness",
            "Choose the best option",
            "Plan the first concrete step",
            "After trying it, review what happened"
        ],
        exampleScripts: [
            "Let's break this down. In one sentence, what's the problem you're facing right now?",
            "Now let's brainstorm — what are all the possible ways you could handle this? Don't filter yet, just generate ideas."
        ],
        durationEstimate: 600,
        successCriteria: "Client defines the problem, generates options, and identifies a first step",
        evidenceBasis: "D'Zurilla & Nezu (2007) Problem-Solving Therapy"
    )
}
