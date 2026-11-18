import Testing
import Foundation
@testable import Services
@testable import Domain

@Suite("ProtocolPatchPipeline")
struct ProtocolPatchPipelineTests {

    private func makePipeline(session: MockURLSession, apiKey: String = "test-key") -> ProtocolPatchPipeline {
        let client = OpenAIAPIClient(
            session: session,
            apiKeyOverride: apiKey,
            maxRetries: 1
        )
        return ProtocolPatchPipeline(apiClient: client, maxRepairAttempts: 3)
    }

    private func makeExistingProtocol() -> CBTProtocol {
        CBTProtocol(
            version: "1.0.0",
            name: "Existing Protocol",
            summary: "An existing protocol for revision",
            whenToUse: ["When anxious"],
            hotThoughtTemplates: ["I can't handle this"],
            targets: ProtocolTargets(targetBelief: "I must be perfect"),
            interventions: [
                InterventionInstance(
                    interventionID: "be-prediction-test",
                    type: .behaviouralExperiment,
                    title: "Prediction Test",
                    script: "Test your prediction.",
                    durationEstimate: 600
                )
            ],
            experiments: [
                Experiment(
                    prediction: "It will go badly",
                    steps: ["Do it", "Record it"],
                    measures: ["anxiety"],
                    successCriteria: "Nothing bad happened"
                )
            ]
        )
    }

    @Test("Successful revision increments version from 1.0.0 to 1.1.0")
    func successfulRevisionIncrementsVersion() async {
        let session = MockURLSession()
        session.enqueueSuccess(content: validRevisionJSON())
        let pipeline = makePipeline(session: session)
        let existing = makeExistingProtocol()

        let result = await pipeline.revise(
            existing: existing,
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Make it focus more on rumination")
            ])
        )

        if case .success(let proto) = result {
            #expect(proto.version == "1.1.0")
        } else {
            Issue.record("Expected success but got \(result)")
        }
    }

    @Test("incrementVersion: 1.0.0 → 1.1.0")
    func incrementVersion100() {
        #expect(ProtocolPatchPipeline.incrementVersion("1.0.0") == "1.1.0")
    }

    @Test("incrementVersion: 2.3.1 → 2.4.0")
    func incrementVersion231() {
        #expect(ProtocolPatchPipeline.incrementVersion("2.3.1") == "2.4.0")
    }

    @Test("Revision preserves original protocol ID")
    func preservesOriginalID() async {
        let session = MockURLSession()
        session.enqueueSuccess(content: validRevisionJSON())
        let pipeline = makePipeline(session: session)
        let existing = makeExistingProtocol()

        let result = await pipeline.revise(
            existing: existing,
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Update this")
            ])
        )

        if case .success(let proto) = result {
            #expect(proto.id == existing.id)
        } else {
            Issue.record("Expected success but got \(result)")
        }
    }

    @Test("Revision system prompt contains existing protocol name")
    func revisionPromptContainsName() {
        let proto = CBTProtocol(name: "My Special Protocol", summary: "Test")
        let prompt = ConversationManager.buildRevisionSystemPrompt(
            existingProtocol: proto,
            runHistorySummary: nil
        )
        #expect(prompt.contains("My Special Protocol"))
    }
}

// MARK: - Helper

private func validRevisionJSON() -> String {
    """
    {
        "id": "\(UUID().uuidString)",
        "version": "1.0.0",
        "name": "Revised Protocol",
        "summary": "An updated protocol",
        "status": "active",
        "whenToUse": ["Feeling anxious"],
        "hotThoughtTemplates": ["I can't cope"],
        "maintainingBehaviours": [],
        "targets": {"targetBelief": "I can handle uncertainty"},
        "captureFields": [
            {"id": "\(UUID().uuidString)", "fieldType": "situation_text", "label": "What's happening?", "isRequired": false},
            {"id": "\(UUID().uuidString)", "fieldType": "emotion_picker", "label": "Emotion", "isRequired": true}
        ],
        "interventions": [{
            "id": "\(UUID().uuidString)",
            "interventionID": "be-prediction-test",
            "type": "behavioural_experiment",
            "title": "Prediction Test",
            "script": "Test your prediction.",
            "steps": [],
            "durationEstimate": 600,
            "isTimed": false
        }],
        "experiments": [{
            "id": "\(UUID().uuidString)",
            "prediction": "It will go badly",
            "steps": ["Do it", "Record it"],
            "measures": ["anxiety"],
            "successCriteria": "Nothing bad happened",
            "outcomes": []
        }],
        "measures": ["emotion"],
        "reviewRules": [
            {"id": "\(UUID().uuidString)", "condition": "after_5_runs", "action": "prompt_review"}
        ],
        "safety": {
            "message": "If you're in crisis, reach out.",
            "resources": [
                {"id": "\(UUID().uuidString)", "name": "Samaritans", "detail": "Call 116 123", "phoneNumber": "116 123"}
            ]
        },
        "formulation": {
            "triggerAppraisalLinks": [],
            "maintainingCycles": []
        },
        "tags": [],
        "exclusions": [],
        "standardisedMeasures": [],
        "escalationRules": [],
        "createdAt": "2026-01-01T00:00:00Z",
        "updatedAt": "2026-01-01T00:00:00Z"
    }
    """
}
