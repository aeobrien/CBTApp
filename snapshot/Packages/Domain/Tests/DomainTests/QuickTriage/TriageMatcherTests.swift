import Testing
import Foundation
@testable import Domain

@Suite("TriageMatcher")
struct TriageMatcherTests {

    @Test("Scores +2 for targetLoop mapping to chosen theme")
    func targetLoopScoresHigher() {
        let proto = CBTProtocol(
            name: "Rumination protocol",
            summary: "For rumination",
            targets: ProtocolTargets(targetBelief: "test", targetLoop: .rumination),
            tags: []
        )
        let answers = TriageAnswers(urge: .scroll, theme: .loss, intensity: 50)
        let matches = TriageMatcher.match(answers: answers, protocols: [proto])

        #expect(matches.count == 1)
        #expect(matches[0].score == 2)
    }

    @Test("Scores +1 for matching tags and maintaining behaviour")
    func tagAndBehaviourScoring() {
        let proto = CBTProtocol(
            name: "Test protocol",
            summary: "For testing",
            maintainingBehaviours: [
                MaintainingBehaviour(type: .avoidance)
            ],
            tags: ["failure", "catastrophe"]
        )
        let answers = TriageAnswers(urge: .avoid, theme: .fearOfFailure, intensity: 70)
        let matches = TriageMatcher.match(answers: answers, protocols: [proto])

        #expect(matches.count == 1)
        // +1 for "failure" tag, +1 for "catastroph" matching "catastrophe", +1 for avoidance behaviour
        #expect(matches[0].score == 3)
    }

    @Test("Returns empty when no protocols match")
    func noMatchReturnsEmpty() {
        let proto = CBTProtocol(
            name: "Unrelated protocol",
            summary: "No overlap",
            tags: ["unrelated"]
        )
        let answers = TriageAnswers(urge: .ruminate, theme: .comparison, intensity: 50)
        let matches = TriageMatcher.match(answers: answers, protocols: [proto])

        #expect(matches.isEmpty)
    }
}
