import XCTest
@testable import Domain

final class RunSummaryTests: XCTestCase {

    // MARK: - Full summary

    func testSummaryWithAllFields() {
        let run = Run(
            protocolID: UUID(),
            timestampStart: Date(),
            timestampEnd: Date().addingTimeInterval(180),
            situation: "Lying in bed worrying",
            hotThought: "Tomorrow will go badly",
            emotions: [EmotionRating(emotion: .anxiety, intensity: 75)],
            bodySignals: [.tightChest],
            urge: .ruminate,
            beliefStrengthBefore: 80,
            predictionResponse: "I'll forget something",
            alternativeResponse: "It might be fine",
            chosenInterventions: ["delay_01"],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: 45)],
            beliefStrengthAfter: 50,
            outcomeTags: [.intensityDropped],
            learningNote: "The delay helped",
            forwardPlan: "Try delay first next time",
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Late-night rumination")

        XCTAssertTrue(summary.contains("Late-night rumination"))
        XCTAssertTrue(summary.contains("Duration:"))
        XCTAssertTrue(summary.contains("Lying in bed worrying"))
        XCTAssertTrue(summary.contains("Tomorrow will go badly"))
        XCTAssertTrue(summary.contains("Anxiety (75)"))
        XCTAssertTrue(summary.contains("Belief strength before: 80%"))
        XCTAssertTrue(summary.contains("delay_01"))
        XCTAssertTrue(summary.contains("Anxiety (45)"))
        XCTAssertTrue(summary.contains("improved"))
        XCTAssertTrue(summary.contains("Belief strength after: 50%"))
        XCTAssertTrue(summary.contains("weakened"))
        XCTAssertTrue(summary.contains("Intensity dropped"))
        XCTAssertTrue(summary.contains("The delay helped"))
        XCTAssertTrue(summary.contains("Try delay first next time"))
    }

    func testSummaryWithMinimalFields() {
        let run = Run(
            protocolID: UUID(),
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")

        XCTAssertTrue(summary.contains("Test"))
        XCTAssertFalse(summary.contains("Situation:"))
        XCTAssertFalse(summary.contains("Hot thought:"))
        XCTAssertFalse(summary.contains("Emotions before:"))
        XCTAssertFalse(summary.contains("Interventions:"))
    }

    func testEmotionChangeImprovement() {
        let run = Run(
            protocolID: UUID(),
            emotions: [EmotionRating(emotion: .anxiety, intensity: 80)],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: 40)],
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("improved"))
    }

    func testEmotionChangeWorsening() {
        let run = Run(
            protocolID: UUID(),
            emotions: [EmotionRating(emotion: .sadness, intensity: 30)],
            emotionsAfter: [EmotionRating(emotion: .sadness, intensity: 60)],
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("worsened"))
    }

    func testEmotionChangeNoChange() {
        let run = Run(
            protocolID: UUID(),
            emotions: [EmotionRating(emotion: .anxiety, intensity: 50)],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: 50)],
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("no change"))
    }

    func testBeliefStrengthWeakened() {
        let run = Run(
            protocolID: UUID(),
            beliefStrengthBefore: 90,
            beliefStrengthAfter: 40,
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("weakened"))
    }

    func testBeliefStrengthStrengthened() {
        let run = Run(
            protocolID: UUID(),
            beliefStrengthBefore: 30,
            beliefStrengthAfter: 70,
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("strengthened"))
    }

    func testDurationFormatMinutesAndSeconds() {
        let start = Date()
        let run = Run(
            protocolID: UUID(),
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(125),
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("2m 5s"))
    }

    func testDurationFormatSecondsOnly() {
        let start = Date()
        let run = Run(
            protocolID: UUID(),
            timestampStart: start,
            timestampEnd: start.addingTimeInterval(45),
            completionStatus: .completed
        )

        let summary = RunSummary.generate(from: run, protocolName: "Test")
        XCTAssertTrue(summary.contains("45s"))
        XCTAssertFalse(summary.contains("0m"))
    }
}
