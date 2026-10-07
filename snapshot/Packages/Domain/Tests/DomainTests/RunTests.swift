import Testing
import Foundation
@testable import Domain

@Suite("Run")
struct RunTests {
    let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    @Test("Minimal run creates with defaults")
    func minimalRun() {
        let protocolID = UUID()
        let run = Run(protocolID: protocolID)
        #expect(run.protocolID == protocolID)
        #expect(run.completionStatus == .abandoned)
        #expect(run.emotions.isEmpty)
        #expect(run.chosenInterventions.isEmpty)
    }

    @Test("Run JSON round-trip preserves all fields")
    func fullRoundTrip() throws {
        let run = Run(
            protocolID: UUID(),
            situation: "Email from boss at 11pm",
            hotThought: "I should have replied faster",
            emotions: [
                EmotionRating(emotion: .anxiety, intensity: 75),
                EmotionRating(emotion: .shame, intensity: 40)
            ],
            bodySignals: [.tightChest, .racingHeart],
            urge: .ruminate,
            beliefStrengthBefore: 80,
            predictionResponse: "They'll think I don't care about the job",
            alternativeResponse: "They sent it late; they probably don't expect an immediate reply",
            chosenInterventions: ["delay_01"],
            emotionsAfter: [
                EmotionRating(emotion: .anxiety, intensity: 45),
                EmotionRating(emotion: .shame, intensity: 20)
            ],
            beliefStrengthAfter: 55,
            urgeAfter: .ruminate,
            outcomeTags: [.intensityDropped, .predictionDidntHappen],
            learningNote: "The prediction didn't happen",
            forwardPlan: "Check email once in the morning",
            helpfulnessRating: .helpful,
            completionStatus: .completed,
            note: "Felt better after the delay"
        )

        let data = try encoder.encode(run)
        let decoded = try decoder.decode(Run.self, from: data)

        #expect(decoded.situation == run.situation)
        #expect(decoded.hotThought == run.hotThought)
        #expect(decoded.emotions.count == 2)
        #expect(decoded.emotions[0].emotion == .anxiety)
        #expect(decoded.emotions[0].intensity == 75)
        #expect(decoded.bodySignals == [.tightChest, .racingHeart])
        #expect(decoded.urge == .ruminate)
        #expect(decoded.beliefStrengthBefore == 80)
        #expect(decoded.predictionResponse == run.predictionResponse)
        #expect(decoded.alternativeResponse == run.alternativeResponse)
        #expect(decoded.outcomeTags.contains(.predictionDidntHappen))
        #expect(decoded.helpfulnessRating == .helpful)
        #expect(decoded.completionStatus == .completed)
    }

    @Test("EmotionRating clamps intensity to 0-100")
    func emotionRatingClamping() {
        let low = EmotionRating(emotion: .anxiety, intensity: -10)
        #expect(low.intensity == 0)

        let high = EmotionRating(emotion: .anxiety, intensity: 150)
        #expect(high.intensity == 100)

        let normal = EmotionRating(emotion: .anxiety, intensity: 50)
        #expect(normal.intensity == 50)
    }

    @Test("Boundary intensity values: 0 and 100")
    func boundaryIntensity() {
        let zero = EmotionRating(emotion: .sadness, intensity: 0)
        #expect(zero.intensity == 0)

        let hundred = EmotionRating(emotion: .sadness, intensity: 100)
        #expect(hundred.intensity == 100)
    }

    @Test("Average emotion before calculation")
    func averageEmotionBefore() {
        let run = Run(
            protocolID: UUID(),
            emotions: [
                EmotionRating(emotion: .anxiety, intensity: 80),
                EmotionRating(emotion: .sadness, intensity: 40)
            ]
        )
        #expect(run.averageEmotionBefore == 60.0)
    }

    @Test("Average emotion after calculation")
    func averageEmotionAfter() {
        let run = Run(
            protocolID: UUID(),
            emotionsAfter: [
                EmotionRating(emotion: .anxiety, intensity: 30),
                EmotionRating(emotion: .sadness, intensity: 10)
            ]
        )
        #expect(run.averageEmotionAfter == 20.0)
    }

    @Test("Emotion change calculation (negative = improvement)")
    func emotionChange() {
        let run = Run(
            protocolID: UUID(),
            emotions: [EmotionRating(emotion: .anxiety, intensity: 80)],
            emotionsAfter: [EmotionRating(emotion: .anxiety, intensity: 40)]
        )
        #expect(run.emotionChange == -40.0)
    }

    @Test("Belief strength change calculation")
    func beliefStrengthChange() {
        let run = Run(
            protocolID: UUID(),
            beliefStrengthBefore: 80,
            beliefStrengthAfter: 55
        )
        #expect(run.beliefStrengthChange == -25)
    }

    @Test("Computed properties return nil for empty data")
    func emptyComputedProperties() {
        let run = Run(protocolID: UUID())
        #expect(run.averageEmotionBefore == nil)
        #expect(run.averageEmotionAfter == nil)
        #expect(run.emotionChange == nil)
        #expect(run.beliefStrengthChange == nil)
        #expect(run.durationSeconds == nil)
    }

    @Test("Duration calculation")
    func durationCalculation() {
        let start = Date()
        let end = start.addingTimeInterval(180) // 3 minutes
        let run = Run(
            protocolID: UUID(),
            timestampStart: start,
            timestampEnd: end
        )
        #expect(run.durationSeconds == 180)
    }
}
