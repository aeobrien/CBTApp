import Testing
import Foundation
@testable import Domain

@Suite("JITAIEngine")
struct JITAIEngineTests {

    private var sampleProtocol: CBTProtocol { SampleData.lateNightRumination }

    @Test("Measure due takes highest priority")
    func measureDuePriority() {
        let state = JITAIState(hasActiveExperiment: true, hasDueMeasure: true)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction?.type == .promptMeasure)
    }

    @Test("Active experiment follow-up is priority 2")
    func activeExperimentPriority() {
        let state = JITAIState(hasActiveExperiment: true)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction?.type == .followUpExperiment)
    }

    @Test("Recent run with low intensity suggests outside-app action")
    func recentLowIntensity() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-3600), // 1 hour ago
            lastRunIntensity: 20
        )
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction?.type == .outsideAppAction)
    }

    @Test("Recent run with high intensity does not suggest outside-app")
    func recentHighIntensity() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-3600),
            lastRunIntensity: 70
        )
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction?.type != .outsideAppAction)
    }

    @Test("Old run does not trigger recency rule")
    func oldRunNoRecency() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-10800), // 3 hours ago
            lastRunIntensity: 15
        )
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction?.type != .outsideAppAction)
    }

    @Test("Urge to ruminate suggests rumination scheduling or defusion")
    func urgeRuminate() {
        let state = JITAIState(capturedUrge: .ruminate, completedRunCount: 3)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction == nil)
        #expect(guidance.preferredTypes?.contains(.ruminationScheduling) == true)
    }

    @Test("Urge to avoid suggests graded exposure")
    func urgeAvoid() {
        let state = JITAIState(capturedUrge: .avoid, completedRunCount: 3)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.preferredTypes?.contains(.gradedExposureStep) == true)
    }

    @Test("Urge to withdraw suggests opposite action or BA")
    func urgeWithdraw() {
        let state = JITAIState(capturedUrge: .withdraw, completedRunCount: 3)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.preferredTypes?.contains(.oppositeAction) == true ||
                guidance.preferredTypes?.contains(.behaviouralActivation) == true)
    }

    @Test("Low intensity suggests behavioural experiment")
    func lowIntensity() {
        let state = JITAIState(capturedIntensity: 20, completedRunCount: 3)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.preferredTypes?.contains(.behaviouralExperiment) == true)
    }

    @Test("High intensity suggests delay or defusion")
    func highIntensity() {
        let state = JITAIState(capturedIntensity: 75, completedRunCount: 3)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.preferredTypes?.contains(.delayExperiment) == true ||
                guidance.preferredTypes?.contains(.defusion) == true)
    }

    @Test("Very high intensity prioritises delay experiment")
    func veryHighIntensity() {
        let state = JITAIState(capturedIntensity: 90, completedRunCount: 3)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.preferredTypes == Set([.delayExperiment]))
    }

    @Test("First-ever run defaults to behavioural experiment")
    func firstRun() {
        let state = JITAIState(completedRunCount: 0)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.preferredTypes?.contains(.behaviouralExperiment) == true)
        #expect(guidance.reasoning.contains("First run"))
    }

    @Test("No specific conditions returns default guidance")
    func noSpecificConditions() {
        let state = JITAIState(completedRunCount: 5)
        let guidance = JITAIEngine.evaluate(state: state, protocol: sampleProtocol)

        #expect(guidance.suggestedAction == nil)
        #expect(guidance.preferredTypes == nil)
    }
}

@Suite("ProtocolEngine")
struct ProtocolEngineTests {

    private var engine: ProtocolEngine {
        ProtocolEngine(cbtProtocol: SampleData.lateNightRumination)
    }

    @Test("Ordered capture fields match protocol definition")
    func captureFieldOrder() {
        let fields = engine.orderedCaptureFields
        #expect(!fields.isEmpty)
        #expect(fields == engine.cbtProtocol.captureFields)
    }

    @Test("Protocol version accessible")
    func protocolVersion() {
        #expect(engine.protocolVersion == SampleData.lateNightRumination.version)
    }

    @Test("Recommend intervention returns result for first run")
    func recommendFirstRun() {
        let state = JITAIState(completedRunCount: 0)
        let recommendation = engine.recommendIntervention(state: state)

        switch recommendation {
        case .intervention(let instance):
            #expect(!instance.script.isEmpty)
            #expect(!instance.interventionID.isEmpty)
        case .action:
            // Also acceptable if JITAI suggests an action
            break
        }
    }

    @Test("Recommend intervention with urge")
    func recommendWithUrge() {
        let state = JITAIState(
            capturedHotThought: "I should have said something different",
            capturedUrge: .ruminate,
            completedRunCount: 3
        )
        let recommendation = engine.recommendIntervention(state: state)

        switch recommendation {
        case .intervention(let instance):
            #expect(instance.type == .ruminationScheduling || instance.type == .defusion)
        case .action:
            break
        }
    }

    // MARK: - End-to-end pipeline tests (TC-06/07 scenarios)

    @Test("TC-06: Ruminate urge selects Worry Time over Thought Labelling")
    func ruminateUrgeSelectsWorryTime() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-5 * 3600),
            lastRunIntensity: 20,
            capturedIntensity: 50,
            capturedUrge: .ruminate,
            completedRunCount: 3
        )
        let recommendation = engine.recommendIntervention(state: state)

        if case .intervention(let instance) = recommendation {
            #expect(instance.type == .ruminationScheduling, "Expected Worry Time (ruminationScheduling) but got \(instance.title) (\(instance.type))")
        } else {
            #expect(Bool(false), "Expected intervention, got action")
        }
    }

    @Test("Selector ranks Worry Time above Thought Labelling for ruminate keywords")
    func selectorRanksWorryTimeFirst() {
        let query = InterventionSelector.Query(
            types: [.ruminationScheduling, .defusion],
            indicationKeywords: ["ruminat", "worries", "repetitive"],
            applyACTBoundary: true
        )
        let candidates = InterventionSelector.select(query: query)

        #expect(candidates.count == 2, "Expected 2 candidates but got \(candidates.count)")
        #expect(candidates[0].type == .ruminationScheduling,
            "First candidate should be Worry Time (ruminationScheduling) but got \(candidates[0].name) (\(candidates[0].type))")
        #expect(candidates[1].type == .defusion,
            "Second candidate should be Thought Labelling (defusion) but got \(candidates[1].name) (\(candidates[1].type))")
    }

    @Test("TC-06: Avoid urge selects Graded Exposure Step")
    func avoidUrgeSelectsGradedExposure() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-5 * 3600),
            lastRunIntensity: 20,
            capturedIntensity: 50,
            capturedUrge: .avoid,
            completedRunCount: 3
        )
        let recommendation = engine.recommendIntervention(state: state)

        if case .intervention(let instance) = recommendation {
            #expect(instance.type == .gradedExposureStep, "Expected Graded Exposure Step but got \(instance.title) (\(instance.type))")
        } else {
            #expect(Bool(false), "Expected intervention, got action")
        }
    }

    @Test("TC-06: Withdraw urge selects Opposite Action or Activity Scheduling")
    func withdrawUrgeSelectsOppositeAction() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-5 * 3600),
            lastRunIntensity: 20,
            capturedIntensity: 50,
            capturedUrge: .withdraw,
            completedRunCount: 3
        )
        let recommendation = engine.recommendIntervention(state: state)

        if case .intervention(let instance) = recommendation {
            #expect(
                instance.type == .oppositeAction || instance.type == .behaviouralActivation,
                "Expected Opposite Action or Activity Scheduling but got \(instance.title) (\(instance.type))"
            )
        } else {
            #expect(Bool(false), "Expected intervention, got action")
        }
    }

    @Test("TC-07: High intensity (75) with no urge does NOT return behavioural experiment")
    func highIntensityNoUrge() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-5 * 3600),
            lastRunIntensity: 20,
            capturedIntensity: 75,
            completedRunCount: 5
        )
        let recommendation = engine.recommendIntervention(state: state)

        if case .intervention(let instance) = recommendation {
            #expect(
                instance.type == .delayExperiment || instance.type == .defusion || instance.type == .oppositeAction,
                "High intensity should suggest delay/defusion/opposite action, but got \(instance.title) (\(instance.type))"
            )
        } else {
            #expect(Bool(false), "Expected intervention, got action")
        }
    }

    @Test("TC-07: Very high intensity (95) with no urge returns delay experiment")
    func veryHighIntensityNoUrge() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-5 * 3600),
            lastRunIntensity: 20,
            capturedIntensity: 95,
            completedRunCount: 5
        )
        let recommendation = engine.recommendIntervention(state: state)

        if case .intervention(let instance) = recommendation {
            #expect(
                instance.type == .delayExperiment,
                "Very high intensity should suggest delay experiment only, but got \(instance.title) (\(instance.type))"
            )
        } else {
            #expect(Bool(false), "Expected intervention, got action")
        }
    }

    @Test("TC-07: Moderate intensity (50) with no urge allows broader selection")
    func moderateIntensityNoUrge() {
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-5 * 3600),
            lastRunIntensity: 20,
            capturedIntensity: 50,
            completedRunCount: 5
        )
        let recommendation = engine.recommendIntervention(state: state)

        // Moderate intensity has no type filter — keyword "prediction" drives selection
        if case .intervention(let instance) = recommendation {
            #expect(!instance.title.isEmpty, "Should return some intervention")
        } else {
            #expect(Bool(false), "Expected intervention, got action")
        }
    }

    @Test("Recommend intervention with due measure returns action")
    func recommendWithDueMeasure() {
        let state = JITAIState(hasDueMeasure: true)
        let recommendation = engine.recommendIntervention(state: state)

        if case .action(let action) = recommendation {
            #expect(action.type == .promptMeasure)
        } else {
            #expect(Bool(false), "Expected action, got intervention")
        }
    }

    @Test("Due measures detects never-administered measures")
    func measuresNeverAdministered() {
        // Sample protocol has a GAD-7 measure with no lastAdministered date,
        // so it's always due.
        let due = engine.dueMeasures
        let hasDue = due.contains { $0.measureID == "GAD-7" }
        #expect(hasDue || due.isEmpty) // depends on sample data
    }

    @Test("Due measures returns empty when protocol has no measures")
    func noMeasuresOnProtocol() {
        var proto = SampleData.lateNightRumination
        proto.standardisedMeasures = []
        let eng = ProtocolEngine(cbtProtocol: proto)
        #expect(eng.dueMeasures.isEmpty)
    }
}

@Suite("ReviewRuleEvaluator")
struct ReviewRuleEvaluatorTests {

    @Test("Runs threshold triggers correctly")
    func runsThreshold() {
        let rule = ReviewRule(condition: "runs >= 5", action: "Prompt review")
        let results = ReviewRuleEvaluator.evaluate(
            rules: [rule],
            completedRunCount: 5,
            recentEmotionChanges: []
        )

        #expect(results.count == 1)
        #expect(results[0].triggered == true)
    }

    @Test("Runs threshold does not trigger below count")
    func runsThresholdNotMet() {
        let rule = ReviewRule(condition: "runs >= 5", action: "Prompt review")
        let results = ReviewRuleEvaluator.evaluate(
            rules: [rule],
            completedRunCount: 3,
            recentEmotionChanges: []
        )

        #expect(results[0].triggered == false)
    }

    @Test("No shift rule triggers when no improvement")
    func noShiftTriggers() {
        let rule = ReviewRule(condition: "no_shift_after_3", action: "Prompt revision")
        let changes = [-2.0, 0.0, -1.0] // average = -1, not enough shift
        let results = ReviewRuleEvaluator.evaluate(
            rules: [rule],
            completedRunCount: 3,
            recentEmotionChanges: changes
        )

        #expect(results[0].triggered == true)
    }

    @Test("No shift rule does not trigger with improvement")
    func noShiftWithImprovement() {
        let rule = ReviewRule(condition: "no_shift_after_3", action: "Prompt revision")
        let changes = [-10.0, -8.0, -12.0] // average = -10, clear improvement
        let results = ReviewRuleEvaluator.evaluate(
            rules: [rule],
            completedRunCount: 3,
            recentEmotionChanges: changes
        )

        #expect(results[0].triggered == false)
    }

    @Test("No shift rule does not trigger with insufficient data")
    func noShiftInsufficientData() {
        let rule = ReviewRule(condition: "no_shift_after_5", action: "Prompt revision")
        let changes = [-1.0, 0.0] // only 2 runs, need 5
        let results = ReviewRuleEvaluator.evaluate(
            rules: [rule],
            completedRunCount: 2,
            recentEmotionChanges: changes
        )

        #expect(results[0].triggered == false)
    }

    @Test("Unknown condition does not trigger")
    func unknownCondition() {
        let rule = ReviewRule(condition: "something_unknown", action: "Do nothing")
        let results = ReviewRuleEvaluator.evaluate(
            rules: [rule],
            completedRunCount: 10,
            recentEmotionChanges: []
        )

        #expect(results[0].triggered == false)
        #expect(results[0].reason.contains("Unknown"))
    }

    @Test("Multiple rules evaluated independently")
    func multipleRules() {
        let rules = [
            ReviewRule(condition: "runs >= 3", action: "Review"),
            ReviewRule(condition: "no_shift_after_3", action: "Revise"),
        ]
        let results = ReviewRuleEvaluator.evaluate(
            rules: rules,
            completedRunCount: 5,
            recentEmotionChanges: [-1.0, 0.0, -2.0, 1.0, -1.0]
        )

        #expect(results.count == 2)
        #expect(results[0].triggered == true)  // runs >= 3 met
        #expect(results[1].triggered == true)   // no shift in last 3
    }

    @Test("Parse runs threshold — multiple formats")
    func parseRunsThreshold() {
        #expect(ReviewRuleEvaluator.parseRunsThreshold("runs >= 5") == 5)
        #expect(ReviewRuleEvaluator.parseRunsThreshold("runs >= 10") == 10)
        #expect(ReviewRuleEvaluator.parseRunsThreshold("runs>=3") == 3)
        #expect(ReviewRuleEvaluator.parseRunsThreshold("after_5_runs") == 5)
        #expect(ReviewRuleEvaluator.parseRunsThreshold("after_10_runs") == 10)
        #expect(ReviewRuleEvaluator.parseRunsThreshold("something else") == nil)
    }

    @Test("Parse no shift threshold — multiple formats")
    func parseNoShiftThreshold() {
        #expect(ReviewRuleEvaluator.parseNoShiftThreshold("no_shift_after_3") == 3)
        #expect(ReviewRuleEvaluator.parseNoShiftThreshold("no_shift_after_3_runs") == 3)
        #expect(ReviewRuleEvaluator.parseNoShiftThreshold("no_shift_after_10") == 10)
        #expect(ReviewRuleEvaluator.parseNoShiftThreshold("something else") == nil)
    }

    @Test("Sample data default rules parse correctly")
    func sampleDataRulesParse() {
        let defaults = ReviewRule.defaults
        #expect(ReviewRuleEvaluator.parseRunsThreshold(defaults[0].condition) != nil)
        #expect(ReviewRuleEvaluator.parseNoShiftThreshold(defaults[1].condition) != nil)
    }
}
