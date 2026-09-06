import Testing
import Foundation
@testable import Domain

@Suite("CBTProtocol")
struct CBTProtocolTests {
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

    @Test("Minimal protocol creates with defaults")
    func minimalProtocol() {
        let p = CBTProtocol(name: "Test", summary: "A test protocol")
        #expect(p.name == "Test")
        #expect(p.version == "1.0.0")
        #expect(p.status == .active)
        #expect(p.captureFields.count == 5)
        #expect(p.reviewRules.count == 2)
        #expect(p.measures == ["emotion", "belief_strength"])
        #expect(p.safety.resources.count == 3)
        #expect(p.tone == "neutral")
    }

    @Test("Protocol JSON round-trip preserves all fields")
    func fullRoundTrip() throws {
        let p = CBTProtocol(
            name: "Late-night rumination",
            summary: "Protocol for rumination episodes after 10pm",
            status: .active,
            whenToUse: ["Lying in bed unable to sleep", "Replaying a conversation"],
            hotThoughtTemplates: ["I should have said something different", "They think I'm incompetent"],
            maintainingBehaviours: [
                MaintainingBehaviour(type: .rumination, shortTermRelief: "Feels like problem-solving", longTermCost: "Keeps me awake, increases anxiety")
            ],
            targets: ProtocolTargets(targetBelief: "If I don't replay it, I'll miss something important", targetLoop: .rumination),
            interventions: [
                InterventionInstance(interventionID: "delay_01", type: .delayExperiment, title: "10-minute delay", script: "Set a timer for 10 minutes. If still bothered, you can ruminate then.", durationEstimate: 600, isTimed: true)
            ],
            experiments: [
                Experiment(prediction: "If I don't replay, I'll forget something critical by morning", steps: ["Notice the urge", "Set a 10-min timer", "Do one body scan"], measures: ["Did I forget anything important?"], successCriteria: "Nothing critical was forgotten")
            ],
            tags: ["night", "rumination"],
            standardisedMeasures: [
                StandardisedMeasure(measureID: "GAD-7", frequency: .fortnightly)
            ],
            escalationRules: [
                EscalationRule(trigger: "GAD-7 increase >= 5 over 2 administrations", action: "show escalation prompt")
            ]
        )

        let data = try encoder.encode(p)
        let decoded = try decoder.decode(CBTProtocol.self, from: data)

        #expect(decoded.name == p.name)
        #expect(decoded.summary == p.summary)
        #expect(decoded.whenToUse == p.whenToUse)
        #expect(decoded.hotThoughtTemplates == p.hotThoughtTemplates)
        #expect(decoded.maintainingBehaviours.count == 1)
        #expect(decoded.targets.targetBelief == p.targets.targetBelief)
        #expect(decoded.targets.targetLoop == .rumination)
        #expect(decoded.interventions.count == 1)
        #expect(decoded.interventions[0].interventionID == "delay_01")
        #expect(decoded.experiments.count == 1)
        #expect(decoded.experiments[0].prediction == p.experiments[0].prediction)
        #expect(decoded.tags == ["night", "rumination"])
        #expect(decoded.standardisedMeasures.count == 1)
        #expect(decoded.standardisedMeasures[0].measureID == "GAD-7")
        #expect(decoded.escalationRules.count == 1)
        #expect(decoded.status == .active)
    }

    @Test("Protocol with all optional fields empty round-trips")
    func emptyOptionalsRoundTrip() throws {
        let p = CBTProtocol(
            name: "Minimal",
            summary: "Bare minimum protocol",
            whenToUse: [],
            hotThoughtTemplates: [],
            maintainingBehaviours: [],
            interventions: [],
            experiments: [],
            tags: [],
            exclusions: [],
            tone: nil,
            defaults: nil,
            standardisedMeasures: [],
            escalationRules: [],
            completionSummary: nil,
            relapsePreventionCard: nil
        )

        let data = try encoder.encode(p)
        let decoded = try decoder.decode(CBTProtocol.self, from: data)
        #expect(decoded.name == p.name)
        #expect(decoded.summary == p.summary)
        #expect(decoded.status == p.status)
        #expect(decoded.whenToUse == p.whenToUse)
        #expect(decoded.hotThoughtTemplates == p.hotThoughtTemplates)
        #expect(decoded.interventions == p.interventions)
        #expect(decoded.experiments == p.experiments)
        #expect(decoded.tags == p.tags)
        #expect(decoded.tone == p.tone)
        #expect(decoded.completionSummary == nil)
        #expect(decoded.relapsePreventionCard == nil)
    }

    @Test("Protocol with all optional fields populated round-trips")
    func allFieldsRoundTrip() throws {
        let p = CBTProtocol(
            name: "Full",
            summary: "Full protocol with every field",
            completionSummary: "I learned that the prediction rarely comes true",
            relapsePreventionCard: RelapsePreventionCard(
                keyTrigger: "Late night email check",
                updatedBelief: "Missing an email overnight is rarely catastrophic",
                bestInterventionID: "delay_01",
                bestInterventionTitle: "10-minute delay",
                summaryNote: "Delay works; the urge passes"
            )
        )

        let data = try encoder.encode(p)
        let decoded = try decoder.decode(CBTProtocol.self, from: data)
        #expect(decoded.completionSummary == p.completionSummary)
        #expect(decoded.relapsePreventionCard == p.relapsePreventionCard)
    }

    @Test("Default capture fields are in correct order")
    func defaultCaptureFieldOrder() {
        let fields = CaptureField.defaultFields
        #expect(fields[0].fieldType == .situationText)
        #expect(fields[1].fieldType == .hotThoughtPicker)
        #expect(fields[2].fieldType == .emotionPicker)
        #expect(fields[3].fieldType == .bodySignalPicker)
        #expect(fields[4].fieldType == .urgePicker)
        #expect(fields[2].isRequired == true)
    }

    @Test("Default review rules are present")
    func defaultReviewRules() {
        let rules = ReviewRule.defaults
        #expect(rules.count == 2)
        #expect(rules[0].condition == "after_5_runs")
        #expect(rules[1].condition == "no_shift_after_3_runs")
    }

    @Test("Safety info has UK defaults")
    func safetyInfoDefaults() {
        let safety = SafetyInfo()
        #expect(safety.resources.count == 3)
        #expect(safety.resources[0].name == "Samaritans")
        #expect(safety.resources[0].phoneNumber == "116 123")
    }
}
