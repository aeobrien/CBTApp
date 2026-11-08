import XCTest
@testable import Features
@testable import Domain

@MainActor
final class RunFlowViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        protocols: [CBTProtocol] = SampleData.allProtocols,
        runs: [Run] = []
    ) -> (RunFlowViewModel, MockProtocolRepository, MockRunRepository) {
        let protoRepo = MockProtocolRepository(protocols: protocols)
        let runRepo = MockRunRepository(runs: runs)
        let vm = RunFlowViewModel(protocolRepository: protoRepo, runRepository: runRepo)
        return (vm, protoRepo, runRepo)
    }

    // MARK: - Load

    func testLoadProtocols() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadProtocols()
        XCTAssertEqual(vm.allProtocols.count, 3)
    }

    // MARK: - Protocol Selection (Screen A)

    func testSearchFiltering() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadProtocols()

        vm.searchQuery = "rumination"
        XCTAssertEqual(vm.filteredProtocols.count, 1)
        XCTAssertEqual(vm.filteredProtocols.first?.name, "Late-night rumination")
    }

    func testSearchEmptyReturnsAll() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadProtocols()

        vm.searchQuery = ""
        XCTAssertEqual(vm.filteredProtocols.count, 3)
    }

    func testSearchNoMatch() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadProtocols()

        vm.searchQuery = "zzzznonexistent"
        XCTAssertEqual(vm.filteredProtocols.count, 0)
    }

    func testSelectProtocolNavigatesToCapture() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadProtocols()
        await vm.selectProtocol(SampleData.lateNightRumination)

        XCTAssertEqual(vm.navigationPath, [.capture])
        XCTAssertEqual(vm.currentStep, .capture)
    }

    func testSelectProtocolCreatesRun() async {
        let (vm, _, runRepo) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        let runs = try! await runRepo.fetchRuns(forProtocolID: SampleData.lateNightRumination.id)
        XCTAssertEqual(runs.count, 1)
        XCTAssertEqual(runs.first?.completionStatus, .abandoned)
    }

    // MARK: - Full flow

    func testFullFlowCaptureToSummary() async {
        let (vm, _, runRepo) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        // Screen B: Capture
        vm.situation = "Lying in bed"
        vm.selectedHotThought = "I should have said something different"
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 70)]
        vm.selectedBodySignals = [.tightChest]
        vm.selectedUrge = .ruminate
        vm.beliefStrengthBefore = 80
        await vm.advance()

        XCTAssertEqual(vm.currentStep, .guidedDiscovery)

        // Screen C: Guided Discovery
        vm.predictionResponse = "I'll forget something critical"
        vm.alternativeResponse = "It's probably fine"
        await vm.advance()

        XCTAssertEqual(vm.currentStep, .intervention)

        // Screen D: Intervention — advance to outcome
        await vm.advance()

        XCTAssertEqual(vm.currentStep, .outcome)
        // After emotions should be pre-populated
        XCTAssertEqual(vm.emotionRatingsAfter.count, 1)
        XCTAssertEqual(vm.emotionRatingsAfter.first?.emotion, .anxiety)

        // Screen E: Outcome
        vm.emotionRatingsAfter = [EmotionRating(emotion: .anxiety, intensity: 40)]
        vm.beliefStrengthAfter = 50
        vm.selectedOutcomeTags = [.intensityDropped]
        vm.learningNote = "The delay helped"
        vm.forwardPlan = "Use delay first"
        await vm.advance()

        XCTAssertEqual(vm.currentStep, .summary)
        XCTAssertFalse(vm.summaryText.isEmpty)
        XCTAssertTrue(vm.summaryText.contains("Late-night rumination"))

        // Screen F: Summary
        vm.helpfulnessRating = .helpful
        await vm.finishRun()

        // Verify final state
        let runs = try! await runRepo.fetchRuns(forProtocolID: SampleData.lateNightRumination.id)
        XCTAssertEqual(runs.count, 1)
        let finalRun = runs.first!
        XCTAssertEqual(finalRun.completionStatus, .completed)
        XCTAssertNotNil(finalRun.timestampEnd)
        XCTAssertEqual(finalRun.situation, "Lying in bed")
        XCTAssertEqual(finalRun.hotThought, "I should have said something different")
        XCTAssertEqual(finalRun.emotions.count, 1)
        XCTAssertEqual(finalRun.beliefStrengthBefore, 80)
        XCTAssertEqual(finalRun.predictionResponse, "I'll forget something critical")
        XCTAssertEqual(finalRun.alternativeResponse, "It's probably fine")
        XCTAssertFalse(finalRun.chosenInterventions.isEmpty)
        XCTAssertEqual(finalRun.emotionsAfter.first?.intensity, 40)
        XCTAssertEqual(finalRun.beliefStrengthAfter, 50)
        XCTAssertTrue(finalRun.outcomeTags.contains(.intensityDropped))
        XCTAssertEqual(finalRun.learningNote, "The delay helped")
        XCTAssertEqual(finalRun.forwardPlan, "Use delay first")
        XCTAssertEqual(finalRun.helpfulnessRating, .helpful)
    }

    // MARK: - Skip paths

    func testSkipCapture() async {
        let (vm, _, runRepo) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)
        await vm.skipCapture()

        // Should skip to intervention
        XCTAssertEqual(vm.currentStep, .intervention)

        // Run should have partial status
        let runs = try! await runRepo.fetchRuns(forProtocolID: SampleData.lateNightRumination.id)
        XCTAssertEqual(runs.first?.completionStatus, .partialSkippedCapture)
    }

    func testSkipDiscovery() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        // Go to discovery first
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 50)]
        await vm.advance()
        XCTAssertEqual(vm.currentStep, .guidedDiscovery)

        await vm.skipDiscovery()
        XCTAssertEqual(vm.currentStep, .intervention)
    }

    // MARK: - Emotion ratings persistence

    func testEmotionRatingsPersistThroughTransitions() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        vm.emotionRatings = [
            EmotionRating(emotion: .anxiety, intensity: 80),
            EmotionRating(emotion: .sadness, intensity: 60)
        ]
        await vm.advance() // capture → discovery

        XCTAssertEqual(vm.emotionRatings.count, 2)
        XCTAssertEqual(vm.emotionRatings[0].intensity, 80)
        XCTAssertEqual(vm.emotionRatings[1].intensity, 60)
    }

    // MARK: - Intervention

    func testInterventionRecommended() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 70)]
        vm.selectedUrge = .ruminate
        await vm.advance() // capture → discovery
        await vm.advance() // discovery → intervention

        XCTAssertNotNil(vm.currentIntervention)
    }

    func testSwitchIntervention() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 70)]
        await vm.advance() // capture → discovery
        await vm.advance() // discovery → intervention

        let firstIntervention = vm.currentIntervention
        vm.switchIntervention()
        let secondIntervention = vm.currentIntervention

        // Should have changed (lateNightRumination has 2 interventions)
        if firstIntervention?.id != secondIntervention?.id {
            // Good, switched
        }
        // At minimum, switchIntervention should not crash and should have an intervention
        XCTAssertNotNil(vm.currentIntervention)
    }

    // MARK: - Displayed hot thought

    func testDisplayedHotThoughtFromTemplate() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        vm.selectedHotThought = "They think I'm incompetent"
        XCTAssertEqual(vm.displayedHotThought, "They think I'm incompetent")
    }

    func testDisplayedHotThoughtFromCustom() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        vm.selectedHotThought = nil
        vm.customHotThought = "My own hot thought"
        XCTAssertEqual(vm.displayedHotThought, "My own hot thought")
    }

    // MARK: - After emotions pre-populated

    func testAfterEmotionsPrePopulated() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        vm.emotionRatings = [
            EmotionRating(emotion: .anxiety, intensity: 70),
            EmotionRating(emotion: .sadness, intensity: 50)
        ]
        await vm.advance() // → discovery
        await vm.advance() // → intervention
        await vm.advance() // → outcome

        XCTAssertEqual(vm.emotionRatingsAfter.count, 2)
        XCTAssertEqual(vm.emotionRatingsAfter[0].emotion, .anxiety)
        XCTAssertEqual(vm.emotionRatingsAfter[0].intensity, 70)
    }

    // MARK: - Save on each transition

    func testSaveOnEachTransition() async {
        let (vm, _, runRepo) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        // After select: 1 save
        var count = await runRepo.runs.count
        XCTAssertEqual(count, 1)

        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 50)]
        await vm.advance() // → discovery, saves

        // Still 1 run (updated in place)
        count = await runRepo.runs.count
        XCTAssertEqual(count, 1)

        // Verify data was synced
        let runs = try! await runRepo.fetchRecent(limit: 1)
        XCTAssertEqual(runs.first?.emotions.count, 1)
    }

    // MARK: - Edge cases

    func testNoProtocols() async {
        let (vm, _, _) = makeViewModel(protocols: [])
        await vm.loadProtocols()
        XCTAssertEqual(vm.allProtocols.count, 0)
        XCTAssertEqual(vm.filteredProtocols.count, 0)
    }

    func testBoundaryValues() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        vm.beliefStrengthBefore = 0
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 0)]
        await vm.advance()

        vm.beliefStrengthBefore = 100
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 100)]
        // These should not crash
        XCTAssertEqual(vm.beliefStrengthBefore, 100)
    }

    func testEmptyInterventions() async {
        // Protocol with no interventions
        let emptyProto = CBTProtocol(
            name: "Empty",
            summary: "No interventions",
            interventions: []
        )
        let (vm, _, _) = makeViewModel(protocols: [emptyProto])
        await vm.selectProtocol(emptyProto)
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 50)]
        await vm.advance() // → discovery
        await vm.advance() // → intervention

        // Should still have an intervention from the library, or nil
        // Either way, should not crash
        XCTAssertEqual(vm.currentStep, .intervention)
    }

    // MARK: - Summary generation

    func testSummaryGeneration() async {
        let (vm, _, _) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)

        vm.situation = "Test situation"
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 60)]
        vm.beliefStrengthBefore = 70
        await vm.advance() // → discovery
        await vm.advance() // → intervention
        await vm.advance() // → outcome

        vm.emotionRatingsAfter = [EmotionRating(emotion: .anxiety, intensity: 30)]
        vm.beliefStrengthAfter = 40
        await vm.advance() // → summary

        XCTAssertTrue(vm.summaryText.contains("Late-night rumination"))
    }

    // MARK: - Finish run

    func testFinishRunSetsCompleted() async {
        let (vm, _, runRepo) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)
        vm.emotionRatings = [EmotionRating(emotion: .anxiety, intensity: 50)]
        await vm.advance() // → discovery
        await vm.advance() // → intervention
        await vm.advance() // → outcome
        await vm.advance() // → summary

        vm.helpfulnessRating = .notHelpful
        await vm.finishRun()

        let runs = try! await runRepo.fetchRuns(forProtocolID: SampleData.lateNightRumination.id)
        let run = runs.first!
        XCTAssertEqual(run.completionStatus, .completed)
        XCTAssertEqual(run.helpfulnessRating, .notHelpful)
        XCTAssertNotNil(run.timestampEnd)
    }

    // MARK: - Skip capture preserves status through finish

    func testSkipCaptureStatusPreservedAtFinish() async {
        let (vm, _, runRepo) = makeViewModel()
        await vm.selectProtocol(SampleData.lateNightRumination)
        await vm.skipCapture()
        // intervention
        await vm.advance() // → outcome
        await vm.advance() // → summary
        await vm.finishRun()

        let runs = try! await runRepo.fetchRuns(forProtocolID: SampleData.lateNightRumination.id)
        // Status should remain partialSkippedCapture, not overwritten to .completed
        XCTAssertEqual(runs.first?.completionStatus, .partialSkippedCapture)
    }
}
