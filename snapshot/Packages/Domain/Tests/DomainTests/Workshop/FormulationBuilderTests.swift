import XCTest
@testable import Domain

final class FormulationBuilderTests: XCTestCase {

    // MARK: - fromCapture

    func testFromCapture_createsLinkWithEmptyAppraisal() {
        let formulation = FormulationBuilder.fromCapture(
            situation: "Presenting at work",
            emotion: .anxiety,
            urge: .avoid
        )

        XCTAssertEqual(formulation.triggerAppraisalLinks.count, 1)
        let link = formulation.triggerAppraisalLinks[0]
        XCTAssertEqual(link.trigger, "Presenting at work")
        XCTAssertEqual(link.appraisal, "")
        XCTAssertEqual(link.emotion, .anxiety)
        XCTAssertEqual(link.behaviour, .avoid)
    }

    func testFromCapture_maintainingCyclesEmpty() {
        let formulation = FormulationBuilder.fromCapture(
            situation: "Test",
            emotion: .sadness,
            urge: .withdraw
        )
        XCTAssertTrue(formulation.maintainingCycles.isEmpty)
    }

    // MARK: - addMaintainingCycles

    func testAddMaintainingCycles_appendsCycles() {
        let formulation = Formulation()
        let behaviours = [
            MaintainingBehaviour(type: .avoidance, shortTermRelief: "Relief", longTermCost: "Missed chances"),
            MaintainingBehaviour(type: .rumination, shortTermRelief: "Feels productive", longTermCost: "Stuck in loop"),
        ]

        let result = FormulationBuilder.addMaintainingCycles(to: formulation, behaviours: behaviours)
        XCTAssertEqual(result.maintainingCycles.count, 2)
        XCTAssertEqual(result.maintainingCycles[0].behaviour, .avoidance)
        XCTAssertEqual(result.maintainingCycles[1].behaviour, .rumination)
    }

    func testAddMaintainingCycles_deduplicatesByType() {
        var formulation = Formulation()
        formulation.maintainingCycles = [
            MaintainingCycle(behaviour: .avoidance, shortTermFunction: "Relief", longTermCost: "Cost")
        ]

        let behaviours = [
            MaintainingBehaviour(type: .avoidance, shortTermRelief: "Different relief", longTermCost: "Different cost"),
            MaintainingBehaviour(type: .checking, shortTermRelief: "Certainty", longTermCost: "Time waste"),
        ]

        let result = FormulationBuilder.addMaintainingCycles(to: formulation, behaviours: behaviours)
        XCTAssertEqual(result.maintainingCycles.count, 2)
        XCTAssertEqual(result.maintainingCycles[0].behaviour, .avoidance)
        XCTAssertEqual(result.maintainingCycles[1].behaviour, .checking)
    }

    func testAddMaintainingCycles_emptyInput() {
        let formulation = Formulation()
        let result = FormulationBuilder.addMaintainingCycles(to: formulation, behaviours: [])
        XCTAssertTrue(result.maintainingCycles.isEmpty)
    }

    // MARK: - setAppraisal

    func testSetAppraisal_fillsFirstLink() {
        let formulation = FormulationBuilder.fromCapture(
            situation: "Meeting",
            emotion: .anxiety,
            urge: .avoid
        )

        let result = FormulationBuilder.setAppraisal(in: formulation, targetBelief: "I'm not good enough")
        XCTAssertEqual(result.triggerAppraisalLinks[0].appraisal, "I'm not good enough")
    }

    func testSetAppraisal_emptyFormulation() {
        let formulation = Formulation()
        let result = FormulationBuilder.setAppraisal(in: formulation, targetBelief: "I'm a failure")
        XCTAssertTrue(result.triggerAppraisalLinks.isEmpty)
    }

    // MARK: - linkIntervention

    func testLinkIntervention_setsCycleTargetID() {
        var formulation = Formulation()
        let cycle = MaintainingCycle(behaviour: .avoidance, shortTermFunction: "Relief", longTermCost: "Cost")
        formulation.maintainingCycles = [cycle]

        let result = FormulationBuilder.linkIntervention(
            in: formulation,
            cycleID: cycle.id,
            interventionID: "be-prediction-test"
        )
        XCTAssertEqual(result.maintainingCycles[0].targetInterventionID, "be-prediction-test")
    }

    func testLinkIntervention_unknownCycleIDNoOp() {
        var formulation = Formulation()
        formulation.maintainingCycles = [
            MaintainingCycle(behaviour: .rumination, shortTermFunction: "Thinking", longTermCost: "Stuck")
        ]

        let result = FormulationBuilder.linkIntervention(
            in: formulation,
            cycleID: UUID(),
            interventionID: "be-survey"
        )
        XCTAssertNil(result.maintainingCycles[0].targetInterventionID)
    }

    // MARK: - Full round-trip

    func testFullFormulationBuild() {
        // Stage 1
        var form = FormulationBuilder.fromCapture(
            situation: "Exam",
            emotion: .anxiety,
            urge: .avoid
        )
        XCTAssertEqual(form.triggerAppraisalLinks.count, 1)

        // Stage 3
        form = FormulationBuilder.addMaintainingCycles(
            to: form,
            behaviours: [MaintainingBehaviour(type: .avoidance)]
        )
        XCTAssertEqual(form.maintainingCycles.count, 1)

        // Stage 4
        form = FormulationBuilder.setAppraisal(in: form, targetBelief: "I'll fail")
        XCTAssertEqual(form.triggerAppraisalLinks[0].appraisal, "I'll fail")

        // Stage 5
        let cycleID = form.maintainingCycles[0].id
        form = FormulationBuilder.linkIntervention(in: form, cycleID: cycleID, interventionID: "graded-exposure-step")
        XCTAssertEqual(form.maintainingCycles[0].targetInterventionID, "graded-exposure-step")
    }
}
