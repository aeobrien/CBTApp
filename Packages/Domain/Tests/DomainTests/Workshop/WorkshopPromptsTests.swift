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
}
