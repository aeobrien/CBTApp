import XCTest
@testable import Domain

final class WorkshopStageTests: XCTestCase {

    func testGuidedStagesHaveIntroExplanation() {
        let guidedStages: [WorkshopStage] = [.recurrence, .maintaining, .targetBelief, .experimentDesign]
        for stage in guidedStages {
            XCTAssertNotNil(stage.introExplanation, "\(stage.title) should have an intro explanation")
            XCTAssertFalse(stage.introExplanation!.isEmpty)
        }
    }

    func testGuidedStagesHaveGoalDescription() {
        let guidedStages: [WorkshopStage] = [.recurrence, .maintaining, .targetBelief, .experimentDesign]
        for stage in guidedStages {
            XCTAssertNotNil(stage.goalDescription, "\(stage.title) should have a goal description")
            XCTAssertFalse(stage.goalDescription!.isEmpty)
        }
    }

    func testNonGuidedStagesHaveNilIntroExplanation() {
        let nonGuidedStages: [WorkshopStage] = [.capture, .interventionSelection, .captureFields, .standardisedMeasures, .reviewRules, .generation]
        for stage in nonGuidedStages {
            XCTAssertNil(stage.introExplanation, "\(stage.title) should not have an intro explanation")
        }
    }

    func testNonGuidedStagesHaveNilGoalDescription() {
        let nonGuidedStages: [WorkshopStage] = [.capture, .interventionSelection, .captureFields, .standardisedMeasures, .reviewRules, .generation]
        for stage in nonGuidedStages {
            XCTAssertNil(stage.goalDescription, "\(stage.title) should not have a goal description")
        }
    }

    func testGoalDescriptionMentionsNext() {
        let guidedStages: [WorkshopStage] = [.recurrence, .maintaining, .targetBelief, .experimentDesign]
        for stage in guidedStages {
            XCTAssertTrue(stage.goalDescription!.contains("Next"), "\(stage.title) goal should mention Next button")
        }
    }
}
