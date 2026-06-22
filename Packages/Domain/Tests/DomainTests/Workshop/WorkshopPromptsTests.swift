import XCTest
@testable import Domain

final class WorkshopPromptsTests: XCTestCase {

    func testGuidedDiscoveryStagesProduceNonEmptyPrompts() {
        let guidedStages: [WorkshopStage] = [.recurrence, .maintaining, .targetBelief, .experimentDesign]
        let context = WorkshopContext()

        for stage in guidedStages {
            let prompt = WorkshopPrompts.systemPrompt(for: stage, context: context)
            XCTAssertFalse(prompt.isEmpty, "Prompt should not be empty for stage \(stage.title)")
            XCTAssertTrue(prompt.contains("CBT"), "Prompt should mention CBT for stage \(stage.title)")
        }
    }

    func testRecurrencePromptIncludesSituation() {
        let context = WorkshopContext(situation: "Meeting at work")
        let prompt = WorkshopPrompts.systemPrompt(for: .recurrence, context: context)
        XCTAssertTrue(prompt.contains("Meeting at work"))
    }

    func testRecurrencePromptIncludesEmotion() {
        let context = WorkshopContext(emotion: .anxiety)
        let prompt = WorkshopPrompts.systemPrompt(for: .recurrence, context: context)
        XCTAssertTrue(prompt.contains("Anxiety"))
    }

    func testTargetBeliefPromptIncludesMaintainingBehaviours() {
        let context = WorkshopContext(
            maintainingBehaviours: [MaintainingBehaviour(type: .avoidance)]
        )
        let prompt = WorkshopPrompts.systemPrompt(for: .targetBelief, context: context)
        XCTAssertTrue(prompt.contains("Avoidance"))
    }

    func testExperimentPromptIncludesTargetBelief() {
        let context = WorkshopContext(targetBelief: "I'm not capable")
        let prompt = WorkshopPrompts.systemPrompt(for: .experimentDesign, context: context)
        XCTAssertTrue(prompt.contains("I'm not capable"))
    }

    func testNonGuidedStageReturnsBasePrompt() {
        let context = WorkshopContext()
        let prompt = WorkshopPrompts.systemPrompt(for: .capture, context: context)
        XCTAssertTrue(prompt.contains("CBT"))
    }

    // MARK: - Completion signals

    func testAllGuidedPromptsContainCompletionSignal() {
        let guidedStages: [WorkshopStage] = [.recurrence, .maintaining, .targetBelief, .experimentDesign]
        let context = WorkshopContext()

        for stage in guidedStages {
            let prompt = WorkshopPrompts.systemPrompt(for: stage, context: context)
            XCTAssertTrue(prompt.contains("COMPLETION"), "Prompt for \(stage.title) should contain COMPLETION section")
            XCTAssertTrue(prompt.contains("Do not ask further questions"), "Prompt for \(stage.title) should instruct not to ask further questions")
        }
    }

    func testCompletionSignalMentionsNextButton() {
        let guidedStages: [WorkshopStage] = [.recurrence, .maintaining, .targetBelief, .experimentDesign]
        let context = WorkshopContext()

        for stage in guidedStages {
            let prompt = WorkshopPrompts.systemPrompt(for: stage, context: context)
            XCTAssertTrue(prompt.contains("Next"), "Prompt for \(stage.title) should mention Next button")
        }
    }

    // MARK: - Recurrence context flows downstream

    func testMaintainingPromptIncludesRecurrenceTriggers() {
        let context = WorkshopContext(recurrenceTriggers: ["morning meetings", "deadlines"])
        let prompt = WorkshopPrompts.systemPrompt(for: .maintaining, context: context)
        XCTAssertTrue(prompt.contains("morning meetings"))
        XCTAssertTrue(prompt.contains("deadlines"))
    }

    func testMaintainingPromptIncludesRecurrenceFrequency() {
        let context = WorkshopContext(recurrenceFrequency: "3 times a week")
        let prompt = WorkshopPrompts.systemPrompt(for: .maintaining, context: context)
        XCTAssertTrue(prompt.contains("3 times a week"))
    }

    func testMaintainingPromptIncludesTimingPattern() {
        let context = WorkshopContext(recurrenceTimingPattern: "Sunday evenings")
        let prompt = WorkshopPrompts.systemPrompt(for: .maintaining, context: context)
        XCTAssertTrue(prompt.contains("Sunday evenings"))
    }

    func testTargetBeliefPromptIncludesRecurrenceTriggers() {
        let context = WorkshopContext(recurrenceTriggers: ["presentations"])
        let prompt = WorkshopPrompts.systemPrompt(for: .targetBelief, context: context)
        XCTAssertTrue(prompt.contains("presentations"))
    }

    func testExperimentPromptIncludesRecurrenceTriggers() {
        let context = WorkshopContext(recurrenceTriggers: ["social events"])
        let prompt = WorkshopPrompts.systemPrompt(for: .experimentDesign, context: context)
        XCTAssertTrue(prompt.contains("social events"))
    }

    func testExperimentPromptIncludesRecurrenceFrequency() {
        let context = WorkshopContext(recurrenceFrequency: "daily")
        let prompt = WorkshopPrompts.systemPrompt(for: .experimentDesign, context: context)
        XCTAssertTrue(prompt.contains("daily"))
    }
}
