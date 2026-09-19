import XCTest
@testable import Features
@testable import Domain

@MainActor
final class WorkshopFlowViewModelTests: XCTestCase {

    private func makeSUT(
        existingProtocol: CBTProtocol? = nil,
        agent: MockAgentService = MockAgentService(),
        repo: MockProtocolRepository = MockProtocolRepository()
    ) -> (WorkshopFlowViewModel, MockAgentService, MockProtocolRepository) {
        let vm = WorkshopFlowViewModel(
            agentService: agent,
            protocolRepository: repo,
            existingProtocol: existingProtocol
        )
        return (vm, agent, repo)
    }

    // MARK: - Navigation

    func testInitialStageIsCapture() {
        let (vm, _, _) = makeSUT()
        XCTAssertEqual(vm.currentStage, .capture)
    }

    func testAdvanceFromCaptureToRecurrence() async {
        let (vm, _, _) = makeSUT()
        vm.situation = "Test situation"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .recurrence)
    }

    func testAdvanceThroughAllStages() async {
        let (vm, _, _) = makeSUT()

        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()
        XCTAssertEqual(vm.currentStage, .recurrence)

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .maintaining)

        vm.identifiedBehaviours = [MaintainingBehaviour(type: .avoidance)]
        await vm.advance()
        XCTAssertEqual(vm.currentStage, .targetBelief)

        vm.confirmedTargetBelief = "I'm not good enough"
        await vm.advance()
        XCTAssertEqual(vm.currentStage, .interventionSelection)

        vm.selectIntervention(InterventionLibrary.allTemplates[0])
        await vm.advance()
        XCTAssertEqual(vm.currentStage, .experimentDesign)

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .captureFields)

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .standardisedMeasures)

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .reviewRules)

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .generation)
    }

    func testGoBackPopsStage() async {
        let (vm, _, _) = makeSUT()
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()
        XCTAssertEqual(vm.currentStage, .recurrence)

        vm.goBack()
        XCTAssertEqual(vm.currentStage, .capture)
    }

    func testGoBackFromCaptureDoesNothing() {
        let (vm, _, _) = makeSUT()
        vm.goBack()
        XCTAssertEqual(vm.currentStage, .capture)
        XCTAssertTrue(vm.navigationPath.isEmpty)
    }

    func testDataPreservedAfterBackAndForward() async {
        let (vm, _, _) = makeSUT()
        vm.situation = "Preserved situation"
        vm.selectedEmotion = .sadness
        vm.selectedUrge = .withdraw
        await vm.advance()

        vm.goBack()
        XCTAssertEqual(vm.situation, "Preserved situation")
        XCTAssertEqual(vm.selectedEmotion, .sadness)
    }

    // MARK: - Stage 1: Capture

    func testCaptureSetsSituationAndEmotion() {
        let (vm, _, _) = makeSUT()
        vm.situation = "At work"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid

        XCTAssertEqual(vm.situation, "At work")
        XCTAssertEqual(vm.selectedEmotion, .anxiety)
        XCTAssertEqual(vm.selectedUrge, .avoid)
    }

    func testAdvanceFromCaptureBuildFormulation() async {
        let (vm, _, _) = makeSUT()
        vm.situation = "Exam"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid

        await vm.advance()

        XCTAssertEqual(vm.formulation.triggerAppraisalLinks.count, 1)
        XCTAssertEqual(vm.formulation.triggerAppraisalLinks[0].trigger, "Exam")
        XCTAssertEqual(vm.formulation.triggerAppraisalLinks[0].emotion, .anxiety)
    }

    func testAdvanceFromCaptureRequiresSituation() async {
        let (vm, _, _) = makeSUT()
        vm.situation = ""

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .capture, "Should not advance with empty situation")
    }

    // MARK: - Guided Discovery

    func testSendMessageCallsAgentService() async {
        let (vm, agent, _) = makeSUT()
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()

        vm.userInput = "Hello"
        await vm.sendMessage()

        XCTAssertEqual(agent.sendMessageCallCount, 1)
    }

    func testAgentResponseAppendedToConversation() async {
        let agent = MockAgentService()
        let (vm, _, _) = makeSUT(agent: agent)
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()

        agent.sendMessageResult = .success("Agent reply")
        vm.userInput = "Tell me more"
        await vm.sendMessage()

        let messages = vm.conversationMessages
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages[0].role, .user)
        XCTAssertEqual(messages[0].content, "Tell me more")
        XCTAssertEqual(messages[1].role, .assistant)
        XCTAssertEqual(messages[1].content, "Agent reply")
    }

    func testIsAgentTypingTogglesDuringSend() async {
        let (vm, _, _) = makeSUT()
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()

        XCTAssertFalse(vm.isAgentTyping)
        vm.userInput = "Hi"
        await vm.sendMessage()
        XCTAssertFalse(vm.isAgentTyping)
    }

    func testConversationPreservedPerStage() async {
        let agent = MockAgentService()
        let (vm, _, _) = makeSUT(agent: agent)
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()

        agent.sendMessageResult = .success("Recurrence reply")
        vm.userInput = "Recurrence question"
        await vm.sendMessage()

        XCTAssertEqual(vm.conversationMessages.count, 2)

        await vm.advance() // → maintaining
        XCTAssertEqual(vm.conversationMessages.count, 0)

        vm.goBack()
        XCTAssertEqual(vm.conversationMessages.count, 2)
    }

    func testAgentFailureShowsErrorMessage() async {
        let agent = MockAgentService()
        let (vm, _, _) = makeSUT(agent: agent)
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()

        agent.sendMessageResult = .failure(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"]))
        vm.userInput = "Hi"
        await vm.sendMessage()

        let messages = vm.conversationMessages
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages[1].role, .assistant)
        XCTAssertTrue(messages[1].content.contains("sorry"))
    }

    // MARK: - Stage 5: Interventions

    func testSelectInterventionAddsToSelection() {
        let (vm, _, _) = makeSUT()
        let template = InterventionLibrary.allTemplates[0]
        vm.selectIntervention(template)

        XCTAssertEqual(vm.selectedInterventions.count, 1)
        XCTAssertEqual(vm.selectedInterventions[0].id, template.id)
    }

    func testDeselectInterventionRemovesFromSelection() {
        let (vm, _, _) = makeSUT()
        let template = InterventionLibrary.allTemplates[0]
        vm.selectIntervention(template)
        vm.deselectIntervention(template)

        XCTAssertTrue(vm.selectedInterventions.isEmpty)
    }

    func testSelectInterventionNoDuplicates() {
        let (vm, _, _) = makeSUT()
        let template = InterventionLibrary.allTemplates[0]
        vm.selectIntervention(template)
        vm.selectIntervention(template)

        XCTAssertEqual(vm.selectedInterventions.count, 1)
    }

    func testAdvanceFromInterventionsRequiresSelection() async {
        let (vm, _, _) = makeSUT()
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance() // → recurrence
        await vm.advance() // → maintaining
        vm.identifiedBehaviours = [MaintainingBehaviour(type: .avoidance)]
        await vm.advance() // → targetBelief
        vm.confirmedTargetBelief = "Belief"
        await vm.advance() // → interventionSelection

        await vm.advance()
        XCTAssertEqual(vm.currentStage, .interventionSelection, "Should not advance without selection")
    }

    // MARK: - Stage 9: Generation

    func testGenerateProtocolCallsAgentService() async {
        let (vm, agent, _) = makeSUT()
        await vm.generateProtocol()

        XCTAssertEqual(agent.generateCallCount, 1)
    }

    func testGenerationContextIncludesAllConversations() async {
        let agent = MockAgentService()
        let (vm, _, _) = makeSUT(agent: agent)
        vm.situation = "Test"
        vm.selectedEmotion = .anxiety
        vm.selectedUrge = .avoid
        await vm.advance()

        agent.sendMessageResult = .success("Reply")
        vm.userInput = "Q"
        await vm.sendMessage()

        await vm.generateProtocol()

        let context = agent.lastGenerationContext
        XCTAssertNotNil(context)
        XCTAssertFalse(context!.workshopMessages.isEmpty)
    }

    func testGenerationSuccessSetsState() async {
        let agent = MockAgentService()
        let proto = CBTProtocol(name: "Generated", summary: "Test proto")
        agent.generateResult = .success(.success(proto))

        let (vm, _, _) = makeSUT(agent: agent)
        await vm.generateProtocol()

        if case .success(let result) = vm.generationState {
            XCTAssertEqual(result.name, "Generated")
        } else {
            XCTFail("Expected success state")
        }
    }

    func testGenerationFailureSetsState() async {
        let agent = MockAgentService()
        agent.generateResult = .success(.repairFailed(errors: ["Invalid name"]))

        let (vm, _, _) = makeSUT(agent: agent)
        await vm.generateProtocol()

        if case .failed(let msg) = vm.generationState {
            XCTAssertTrue(msg.contains("Invalid name"))
        } else {
            XCTFail("Expected failed state")
        }
    }

    func testGenerationSavesProtocol() async {
        let agent = MockAgentService()
        let proto = CBTProtocol(name: "Saved", summary: "Test")
        agent.generateResult = .success(.success(proto))
        let repo = MockProtocolRepository()

        let (vm, _, _) = makeSUT(agent: agent, repo: repo)
        await vm.generateProtocol()

        let count = try? await repo.count(status: nil)
        XCTAssertEqual(count, 1)
    }

    // MARK: - Revision Mode

    func testRevisionModeWithExistingProtocol() {
        let proto = CBTProtocol(name: "Existing", summary: "To revise")
        let (vm, _, _) = makeSUT(existingProtocol: proto)

        XCTAssertTrue(vm.isRevisionMode)
    }

    func testRevisionModePreFillsState() {
        let proto = CBTProtocol(
            name: "Existing",
            summary: "Revise me",
            hotThoughtTemplates: ["I'm going to fail"],
            targets: ProtocolTargets(targetBelief: "I'm not capable"),
            formulation: Formulation(
                triggerAppraisalLinks: [
                    TriggerAppraisalLink(trigger: "Exam", appraisal: "I'll fail", emotion: .anxiety, behaviour: .avoid)
                ]
            )
        )
        let (vm, _, _) = makeSUT(existingProtocol: proto)
        vm.loadExistingProtocol()

        XCTAssertEqual(vm.situation, "Exam")
        XCTAssertEqual(vm.hotThought, "I'm going to fail")
        XCTAssertEqual(vm.selectedEmotion, .anxiety)
        XCTAssertEqual(vm.confirmedTargetBelief, "I'm not capable")
    }

    func testRevisionCallsReviseProtocol() async {
        let proto = CBTProtocol(name: "Existing", summary: "Revise")
        let (vm, agent, _) = makeSUT(existingProtocol: proto)

        await vm.generateProtocol()

        XCTAssertEqual(agent.reviseCallCount, 1)
        XCTAssertEqual(agent.generateCallCount, 0)
    }

    func testRevisionPreservesOriginalProtocolID() async {
        let originalID = UUID()
        let proto = CBTProtocol(id: originalID, name: "Existing", summary: "Revise")
        let (vm, agent, _) = makeSUT(existingProtocol: proto)

        await vm.generateProtocol()

        XCTAssertEqual(agent.lastRevisionProtocol?.id, originalID)
    }

    // MARK: - Stage 2: Recurrence

    func testRecurrencePropertiesInitiallyEmpty() {
        let (vm, _, _) = makeSUT()
        XCTAssertTrue(vm.recurrenceTriggers.isEmpty)
        XCTAssertTrue(vm.recurrenceFrequency.isEmpty)
        XCTAssertTrue(vm.recurrenceTimingPattern.isEmpty)
    }

    func testRecurrenceDataIncludedInGenerationSummary() async {
        let agent = MockAgentService()
        let (vm, _, _) = makeSUT(agent: agent)

        vm.recurrenceTriggers = ["morning meetings", "deadlines"]
        vm.recurrenceFrequency = "3 times a week"
        vm.recurrenceTimingPattern = "weekday mornings"

        await vm.generateProtocol()

        let context = agent.lastGenerationContext
        XCTAssertNotNil(context)
        let summaryMessage = context!.workshopMessages.last?.content ?? ""
        XCTAssertTrue(summaryMessage.contains("morning meetings"))
        XCTAssertTrue(summaryMessage.contains("3 times a week"))
        XCTAssertTrue(summaryMessage.contains("weekday mornings"))
    }

    func testRevisionPreFillsRecurrenceTriggers() {
        let proto = CBTProtocol(
            name: "Existing",
            summary: "Revise me",
            whenToUse: ["Before presentations", "Monday mornings"]
        )
        let (vm, _, _) = makeSUT(existingProtocol: proto)
        vm.loadExistingProtocol()

        XCTAssertEqual(vm.recurrenceTriggers, ["Before presentations", "Monday mornings"])
    }
}
