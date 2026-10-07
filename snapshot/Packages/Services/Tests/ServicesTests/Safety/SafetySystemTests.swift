import Testing
import Foundation
@testable import Services
@testable import Domain

// MARK: - AcuteRiskClassifier Tests

@Suite("AcuteRiskClassifier")
struct AcuteRiskClassifierTests {

    @Test("Direct self-harm phrase triggers acute")
    func directSelfHarm() {
        let level = AcuteRiskClassifier.classify("I want to kill myself")
        #expect(level == .acute)
    }

    @Test("Suicidal keyword triggers acute")
    func suicidalKeyword() {
        let level = AcuteRiskClassifier.classify("I'm feeling suicidal today")
        #expect(level == .acute)
    }

    @Test("Passive ideation triggers elevated")
    func passiveIdeation() {
        let level = AcuteRiskClassifier.classify("I'd be better off dead")
        #expect(level == .elevated)
    }

    @Test("Hopelessness triggers elevated")
    func hopelessness() {
        let level = AcuteRiskClassifier.classify("There's no hope left")
        #expect(level == .elevated)
    }

    @Test("Benign anxiety text returns none")
    func benignAnxiety() {
        let level = AcuteRiskClassifier.classify("I'm worried about my presentation tomorrow and feeling anxious")
        #expect(level == .none)
    }

    @Test("Metaphorical language returns none")
    func metaphorical() {
        let level = AcuteRiskClassifier.classify("I could kill for a coffee right now")
        #expect(level == .none)
    }

    @Test("Unicode and emoji with crisis text triggers acute")
    func unicodeWithCrisis() {
        let level = AcuteRiskClassifier.classify("😢 I want to end my life")
        #expect(level == .acute)
    }

    @Test("Empty string returns none")
    func emptyString() {
        let level = AcuteRiskClassifier.classify("")
        #expect(level == .none)
    }
}

// MARK: - EscalationEvaluator Tests

@Suite("EscalationEvaluator")
struct EscalationEvaluatorTests {

    private func makeScore(
        totalScore: Int,
        daysAgo: Int = 0,
        itemResponses: [Int]? = nil
    ) -> MeasureScore {
        MeasureScore(
            date: Date().addingTimeInterval(-Double(daysAgo) * 86400),
            totalScore: totalScore,
            itemResponses: itemResponses
        )
    }

    @Test("PHQ-9 increase of 5 triggers alert")
    func phq9IncreaseFive() {
        let scores = [
            makeScore(totalScore: 10, daysAgo: 14),
            makeScore(totalScore: 15, daysAgo: 0)
        ]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result != nil)
        #expect(result?.kind == .chronicNonResponse)
        #expect(result?.canContinue == true)
    }

    @Test("PHQ-9 increase exactly 5 triggers alert (boundary)")
    func phq9ExactlyFive() {
        let scores = [
            makeScore(totalScore: 8, daysAgo: 14),
            makeScore(totalScore: 13, daysAgo: 0)
        ]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result != nil)
        #expect(result?.kind == .chronicNonResponse)
    }

    @Test("PHQ-9 increase of 4 returns nil")
    func phq9IncreaseFour() {
        let scores = [
            makeScore(totalScore: 10, daysAgo: 14),
            makeScore(totalScore: 14, daysAgo: 0)
        ]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result == nil)
    }

    @Test("PHQ-9 decrease returns nil")
    func phq9Decrease() {
        let scores = [
            makeScore(totalScore: 15, daysAgo: 14),
            makeScore(totalScore: 10, daysAgo: 0)
        ]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result == nil)
    }

    @Test("Only 1 score returns nil")
    func singleScore() {
        let scores = [makeScore(totalScore: 20)]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result == nil)
    }

    @Test("Item 9 >= 1 triggers acute alert")
    func item9Suicidality() {
        let items = [0, 1, 2, 1, 0, 1, 1, 0, 1] // item 9 (index 8) = 1
        let scores = [
            makeScore(totalScore: 7, daysAgo: 14),
            makeScore(totalScore: 7, daysAgo: 0, itemResponses: items)
        ]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result != nil)
        #expect(result?.kind == .acuteRisk)
        #expect(result?.canContinue == false)
    }

    @Test("Item 9 = 0 returns no suicidality alert")
    func item9Zero() {
        let items = [0, 1, 2, 1, 0, 1, 1, 0, 0] // item 9 = 0
        let scores = [
            makeScore(totalScore: 6, daysAgo: 14),
            makeScore(totalScore: 6, daysAgo: 0, itemResponses: items)
        ]
        let result = EscalationEvaluator.evaluate(scores: scores)
        #expect(result == nil)
    }
}

// MARK: - SafetySystem Composition Tests

@Suite("SafetySystem Composition")
struct SafetySystemCompositionTests {

    @Test("scanText delegates to AcuteRiskClassifier")
    func scanTextDelegates() {
        let system = SafetySystem()
        let alert = system.scanText("I want to kill myself")
        #expect(alert != nil)
        #expect(alert?.kind == .acuteRisk)
    }

    @Test("evaluateChronicNonResponse delegates to EscalationEvaluator")
    func chronicNonResponseDelegates() {
        let system = SafetySystem()
        let scores = [
            MeasureScore(date: Date().addingTimeInterval(-86400 * 14), totalScore: 10),
            MeasureScore(date: Date(), totalScore: 16)
        ]
        let alert = system.evaluateChronicNonResponse(scores: scores)
        #expect(alert != nil)
        #expect(alert?.kind == .chronicNonResponse)
    }

    @Test("evaluateDisengagement delegates to DisengagementDetector")
    func disengagementDelegates() {
        let system = SafetySystem()
        let protocolID = UUID()
        let runs = [
            Run(
                protocolID: protocolID,
                timestampStart: Date().addingTimeInterval(-86400 * 20),
                timestampEnd: Date().addingTimeInterval(-86400 * 20 + 180),
                completionStatus: .completed
            )
        ]
        let alert = system.evaluateDisengagement(runs: runs, relativeTo: Date())
        #expect(alert != nil)
        #expect(alert?.kind == .disengagement)
    }
}
