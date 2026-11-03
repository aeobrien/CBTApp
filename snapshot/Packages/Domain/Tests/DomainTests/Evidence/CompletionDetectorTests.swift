import XCTest
@testable import Domain

final class CompletionDetectorTests: XCTestCase {

    private var sampleProtocol: CBTProtocol {
        SampleData.lateNightRumination
    }

    private func makeRun(
        emotionBefore: Int = 60,
        emotionAfter: Int = 30,
        beliefBefore: Int = 50,
        beliefAfter: Int = 25,
        tags: [OutcomeTag] = [.intensityDropped],
        daysAgo: Double = 0
    ) -> Run {
        let start = Date().addingTimeInterval(-daysAgo * 86400)
        return Run(
            protocolID: sampleProtocol.id,
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(180),
            emotions: [EmotionRating(emotion: .anxiety, intensity: emotionBefore)],
            beliefStrengthBefore: beliefBefore,
            chosenInterventions: ["delay_01"],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: emotionAfter)],
            beliefStrengthAfter: beliefAfter,
            outcomeTags: tags,
            helpfulnessRating: .helpful,
            completionStatus: .completed
        )
    }

    func testFewerThan5RunsNotCandidate() {
        let runs = (0..<4).map { makeRun(daysAgo: Double($0)) }
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertFalse(result.isCandidate)
        XCTAssertTrue(result.reason.contains("5"))
    }

    func testFiveRunsImprovingIsCandidate() {
        let runs = (0..<5).map { makeRun(
            emotionBefore: 60,
            emotionAfter: 30,
            beliefAfter: 25,
            tags: [.intensityDropped],
            daysAgo: Double($0)
        )}
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertTrue(result.isCandidate)
    }

    func testGotWorseInRecentRunsNotCandidate() {
        var runs = (0..<5).map { makeRun(daysAgo: Double($0)) }
        runs[0] = makeRun(tags: [.gotWorse], daysAgo: 0) // most recent
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertFalse(result.isCandidate)
    }

    func testHighBeliefStrengthNotCandidate() {
        let runs = (0..<5).map { makeRun(beliefAfter: 50, daysAgo: Double($0)) }
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertFalse(result.isCandidate)
    }

    func testCandidateSuggestsTriggerFromProtocol() {
        let runs = (0..<5).map { makeRun(daysAgo: Double($0)) }
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertTrue(result.isCandidate)
        XCTAssertEqual(result.suggestedKeyTrigger, sampleProtocol.whenToUse.first)
    }

    func testCandidateSuggestsMostUsedIntervention() {
        let runs = (0..<5).map { makeRun(daysAgo: Double($0)) }
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertTrue(result.isCandidate)
        XCTAssertEqual(result.suggestedBestInterventionID, "delay_01")
    }

    func testAllNilEmotionBeliefNotCandidate() {
        let runs = (0..<5).map { _ in
            Run(
                protocolID: sampleProtocol.id,
                completionStatus: .completed
            )
        }
        let result = CompletionDetector.evaluate(cbtProtocol: sampleProtocol, runs: runs)
        XCTAssertFalse(result.isCandidate)
    }
}
