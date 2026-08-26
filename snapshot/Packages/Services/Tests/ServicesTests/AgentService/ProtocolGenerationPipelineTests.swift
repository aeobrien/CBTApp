import Testing
import Foundation
@testable import Services
@testable import Domain

// MARK: - Test Helpers

/// Build a valid CBTProtocol JSON string for mock responses.
private func validProtocolJSON(
    name: String = "Test Protocol",
    scriptLength: Int? = nil,
    interventionID: String = "be-prediction-test"
) -> String {
    let script: String
    if let length = scriptLength {
        script = String(repeating: "a", count: length)
    } else {
        script = "Test your prediction by doing the thing."
    }

    return """
    {
        "id": "\(UUID().uuidString)",
        "version": "1.0.0",
        "name": "\(name)",
        "summary": "A protocol for testing",
        "status": "active",
        "whenToUse": ["Feeling anxious"],
        "hotThoughtTemplates": ["I can't cope"],
        "maintainingBehaviours": [],
        "targets": {"targetBelief": "I must be perfect"},
        "captureFields": [
            {"id": "\(UUID().uuidString)", "fieldType": "situation_text", "label": "What's happening?", "isRequired": false},
            {"id": "\(UUID().uuidString)", "fieldType": "emotion_picker", "label": "Emotion", "isRequired": true}
        ],
        "interventions": [{
            "id": "\(UUID().uuidString)",
            "interventionID": "\(interventionID)",
            "type": "behavioural_experiment",
            "title": "Prediction Test",
            "script": "\(script)",
            "steps": [],
            "durationEstimate": 600,
            "isTimed": false
        }],
        "experiments": [{
            "id": "\(UUID().uuidString)",
            "prediction": "It will go badly",
            "steps": ["Do the thing", "Record what happened"],
            "measures": ["anxiety"],
            "successCriteria": "Nothing bad happened",
            "outcomes": []
        }],
        "measures": ["emotion", "belief_strength"],
        "reviewRules": [
            {"id": "\(UUID().uuidString)", "condition": "after_5_runs", "action": "prompt_review"}
        ],
        "safety": {
            "message": "If you're in crisis, please reach out.",
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
        "tone": "neutral",
        "standardisedMeasures": [],
        "escalationRules": [],
        "createdAt": "2026-01-01T00:00:00Z",
        "updatedAt": "2026-01-01T00:00:00Z"
    }
    """
}

// MARK: - Pipeline Tests

@Suite("ProtocolGenerationPipeline")
struct ProtocolGenerationPipelineTests {

    private func makePipeline(session: MockURLSession, apiKey: String = "test-key") -> ProtocolGenerationPipeline {
        let client = OpenAIAPIClient(
            session: session,
            apiKeyOverride: apiKey,
            maxRetries: 1
        )
        return ProtocolGenerationPipeline(apiClient: client, maxRepairAttempts: 3)
    }

    @Test("Valid JSON response produces success with decoded protocol")
    func validResponse() async {
        let session = MockURLSession()
        session.enqueueSuccess(content: validProtocolJSON())
        let pipeline = makePipeline(session: session)

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "I have anxiety about work")
            ])
        )

        if case .success(let proto) = result {
            #expect(proto.name == "Test Protocol")
            #expect(proto.status == .active)
        } else {
            Issue.record("Expected success but got \(result)")
        }
    }

    @Test("First response invalid (script too long), second valid — success after 1 repair")
    func repairOnInvalidScript() async {
        let session = MockURLSession()
        // First: script too long (241 chars)
        session.enqueueSuccess(content: validProtocolJSON(scriptLength: 241))
        // Second: valid
        session.enqueueSuccess(content: validProtocolJSON())
        let pipeline = makePipeline(session: session)

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Help me")
            ])
        )

        if case .success(let proto) = result {
            #expect(proto.name == "Test Protocol")
        } else {
            Issue.record("Expected success after repair but got \(result)")
        }
        #expect(session.requests.count == 2)
    }

    @Test("Three consecutive invalid responses produce repairFailed")
    func threeInvalidResponses() async {
        let session = MockURLSession()
        // All three: script too long
        session.enqueueSuccess(content: validProtocolJSON(scriptLength: 241))
        session.enqueueSuccess(content: validProtocolJSON(scriptLength: 241))
        session.enqueueSuccess(content: validProtocolJSON(scriptLength: 241))
        let pipeline = makePipeline(session: session)

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Help me")
            ])
        )

        if case .repairFailed(let errors) = result {
            #expect(!errors.isEmpty)
        } else {
            Issue.record("Expected repairFailed but got \(result)")
        }
    }

    @Test("No JSON in response triggers repair")
    func noJSONInResponse() async {
        let session = MockURLSession()
        session.enqueueSuccess(content: "Sorry, I can't do that.")
        session.enqueueSuccess(content: validProtocolJSON())
        let pipeline = makePipeline(session: session)

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Help")
            ])
        )

        if case .success = result {
            // OK — repaired on second attempt
        } else {
            Issue.record("Expected success after repair but got \(result)")
        }
    }

    @Test("Invalid interventionID triggers repair")
    func invalidInterventionID() async {
        let session = MockURLSession()
        session.enqueueSuccess(content: validProtocolJSON(interventionID: "bogus-id"))
        session.enqueueSuccess(content: validProtocolJSON())
        let pipeline = makePipeline(session: session)

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Help")
            ])
        )

        if case .success = result {
            // Repaired
        } else {
            Issue.record("Expected success after repair but got \(result)")
        }
    }

    @Test("Network error produces networkError result")
    func networkError() async {
        let session = MockURLSession()
        session.errorToThrow = URLError(.notConnectedToInternet)
        let pipeline = makePipeline(session: session)

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Help")
            ])
        )

        if case .networkError = result {
            // OK
        } else {
            Issue.record("Expected networkError but got \(result)")
        }
    }

    @Test("Decoded protocol has createdAt and updatedAt set to approximately now")
    func timestampsSetToNow() async {
        let session = MockURLSession()
        session.enqueueSuccess(content: validProtocolJSON())
        let pipeline = makePipeline(session: session)
        let before = Date()

        let result = await pipeline.generate(
            context: GenerationContext(workshopMessages: [
                ConversationMessage(role: .user, content: "Help")
            ])
        )

        let after = Date()
        if case .success(let proto) = result {
            #expect(proto.createdAt >= before && proto.createdAt <= after)
            #expect(proto.updatedAt >= before && proto.updatedAt <= after)
        } else {
            Issue.record("Expected success but got \(result)")
        }
    }
}
