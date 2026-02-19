import Foundation

/// Sample protocols and runs for previews and testing.
public enum SampleData {

    // MARK: - Sample Protocols

    public static let lateNightRumination = CBTProtocol(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        name: "Late-night rumination",
        summary: "For when you're lying awake replaying conversations or worrying about tomorrow.",
        whenToUse: ["Lying in bed unable to sleep", "Replaying a conversation from the day", "Worrying about tomorrow's meeting"],
        hotThoughtTemplates: [
            "I should have said something different",
            "They think I'm incompetent",
            "Tomorrow is going to go badly"
        ],
        maintainingBehaviours: [
            MaintainingBehaviour(type: .rumination, shortTermRelief: "Feels like problem-solving", longTermCost: "Keeps me awake, increases next-day anxiety")
        ],
        targets: ProtocolTargets(targetBelief: "If I don't replay it, I'll miss something important", targetLoop: .rumination),
        interventions: [
            InterventionInstance(
                interventionID: "delay_01",
                type: .delayExperiment,
                title: "10-minute delay",
                script: "Set a timer for 10 minutes. If still bothered after, you can ruminate then.",
                durationEstimate: 600,
                isTimed: true
            ),
            InterventionInstance(
                interventionID: "defusion_01",
                type: .defusion,
                title: "Thought labelling",
                script: "Notice the thought. Say to yourself: 'I'm having the thought that...'",
                durationEstimate: 30
            )
        ],
        experiments: [
            Experiment(
                prediction: "If I don't replay the conversation, I'll forget something critical by morning",
                steps: ["Notice the urge to replay", "Set a 10-min timer", "Do one body scan", "Check in the morning: did I forget anything important?"],
                measures: ["Did I forget anything important?", "How did I feel in the morning?"],
                successCriteria: "Nothing critical was forgotten"
            )
        ],
        tags: ["night", "rumination", "sleep"],
        standardisedMeasures: [
            StandardisedMeasure(measureID: "GAD-7", frequency: .fortnightly)
        ]
    )

    public static let comparisonScrolling = CBTProtocol(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        name: "Social comparison scrolling",
        summary: "For when scrolling social media triggers comparison and inadequacy.",
        whenToUse: ["Scrolling Instagram/LinkedIn", "Seeing someone's achievement post", "Feeling behind in life"],
        hotThoughtTemplates: [
            "Everyone is doing better than me",
            "I'm falling behind",
            "I should be further along by now"
        ],
        maintainingBehaviours: [
            MaintainingBehaviour(type: .scrolling, shortTermRelief: "Checking feels like staying informed", longTermCost: "Increases inadequacy, wastes time"),
            MaintainingBehaviour(type: .avoidance, shortTermRelief: "Avoids facing own goals", longTermCost: "Goals stay unaddressed")
        ],
        targets: ProtocolTargets(targetBelief: "Other people's visible success means I'm failing", targetLoop: .socialComparison),
        interventions: [
            InterventionInstance(
                interventionID: "opposite_01",
                type: .oppositeAction,
                title: "Close and do one thing",
                script: "Close the app. Pick one small task from your own list. Do it for 5 minutes.",
                steps: ["Close social media", "Open your task list", "Pick the smallest item", "Work on it for 5 minutes"],
                durationEstimate: 300
            )
        ],
        experiments: [
            Experiment(
                prediction: "If I stop scrolling, I'll miss something important",
                steps: ["Put phone in another room for 1 hour", "Note what you did instead", "Check: did you miss anything that actually mattered?"],
                measures: ["Did I miss anything important?", "How did I feel after the hour?"],
                successCriteria: "Nothing important was missed; felt better or neutral"
            )
        ],
        tags: ["social_media", "comparison", "inadequacy"],
        standardisedMeasures: [
            StandardisedMeasure(measureID: "PHQ-9", frequency: .fortnightly)
        ]
    )

    public static let workPerfectionism = CBTProtocol(
        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
        name: "Work perfectionism",
        summary: "For when perfectionism leads to overworking, checking, or procrastination.",
        whenToUse: ["Re-reading an email for the 5th time", "Working past midnight to 'get it right'", "Avoiding starting because it won't be good enough"],
        hotThoughtTemplates: [
            "If this isn't perfect, people will judge me",
            "One mistake will ruin everything",
            "I need to check one more time"
        ],
        maintainingBehaviours: [
            MaintainingBehaviour(type: .checking, shortTermRelief: "Reduces uncertainty briefly", longTermCost: "Never feels 'done', increases anxiety"),
            MaintainingBehaviour(type: .overworking, shortTermRelief: "Feels productive", longTermCost: "Burnout, no rest, diminishing returns")
        ],
        targets: ProtocolTargets(targetBelief: "If I don't check thoroughly, a serious mistake will slip through", targetLoop: .perfectionism),
        interventions: [
            InterventionInstance(
                interventionID: "be_01",
                type: .behaviouralExperiment,
                title: "Send after one read",
                script: "Read the email once. Send it. Note what actually happens.",
                durationEstimate: 60
            ),
            InterventionInstance(
                interventionID: "delay_02",
                type: .delayExperiment,
                title: "Stop at 'good enough'",
                script: "Set a deadline. When it hits, submit whatever you have. Track the outcome.",
                durationEstimate: 120,
                isTimed: true
            )
        ],
        experiments: [
            Experiment(
                prediction: "If I send the email after one read, there will be an embarrassing mistake",
                steps: ["Write the email", "Read it once", "Send it", "Track: was there an embarrassing mistake?"],
                measures: ["Was there a mistake?", "Did anyone notice?", "How anxious was I after sending? (0-100)"],
                successCriteria: "No significant mistake, or mistake was minor and easily corrected"
            )
        ],
        tags: ["work", "perfectionism", "checking"]
    )

    public static let allProtocols: [CBTProtocol] = [
        lateNightRumination,
        comparisonScrolling,
        workPerfectionism
    ]

    // MARK: - Sample Runs

    public static func sampleRuns(forProtocolID protocolID: UUID, count: Int = 5) -> [Run] {
        (0..<count).map { i in
            let daysAgo = Double(count - i)
            let start = Date().addingTimeInterval(-daysAgo * 86400)
            let beforeIntensity = max(30, 80 - i * 8)
            let afterIntensity = max(15, beforeIntensity - 25 + i * 3)
            let beliefBefore = max(30, 85 - i * 7)
            let beliefAfter = max(20, beliefBefore - 20 + i * 2)

            return Run(
                protocolID: protocolID,
                timestampStart: start,
                timestampEnd: start.addingTimeInterval(Double.random(in: 120...300)),
                situation: "Sample situation \(i + 1)",
                hotThought: "Sample hot thought",
                emotions: [EmotionRating(emotion: .anxiety, intensity: beforeIntensity)],
                bodySignals: [.tightChest],
                urge: .ruminate,
                beliefStrengthBefore: beliefBefore,
                predictionResponse: "It will go badly",
                alternativeResponse: "It might be fine",
                chosenInterventions: ["delay_01"],
                emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: afterIntensity)],
                beliefStrengthAfter: beliefAfter,
                outcomeTags: afterIntensity < beforeIntensity ? [.intensityDropped] : [.sameButTolerable],
                helpfulnessRating: .helpful,
                completionStatus: .completed
            )
        }
    }
}
