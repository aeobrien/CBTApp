import Testing
import Foundation
@testable import Services
@testable import Domain

// MARK: - Test Helpers

/// A valid protocol using real library intervention IDs.
private func makeValidProtocol(
    name: String = "Test Protocol",
    summary: String = "A test protocol for validation",
    version: String = "1.0.0",
    whenToUse: [String] = ["Feeling anxious"],
    hotThoughtTemplates: [String] = ["I can't cope"],
    interventions: [InterventionInstance]? = nil,
    experiments: [Experiment]? = nil,
    safety: SafetyInfo = SafetyInfo(),
    targets: ProtocolTargets = ProtocolTargets(targetBelief: "I must be perfect"),
    defaults: ProtocolDefaults? = nil,
    relapsePreventionCard: RelapsePreventionCard? = nil,
    formulation: Formulation = Formulation()
) -> CBTProtocol {
    let defaultInterventions = [
        InterventionInstance(
            interventionID: "be-prediction-test",
            type: .behaviouralExperiment,
            title: "Prediction Test",
            script: "Test your prediction by doing the thing you're afraid of.",
            durationEstimate: 600
        )
    ]
    let defaultExperiments = [
        Experiment(
            prediction: "It will go badly",
            steps: ["Do the thing", "Record what happened"],
            measures: ["anxiety"],
            successCriteria: "Nothing bad happened"
        )
    ]
    return CBTProtocol(
        version: version,
        name: name,
        summary: summary,
        whenToUse: whenToUse,
        hotThoughtTemplates: hotThoughtTemplates,
        targets: targets,
        interventions: interventions ?? defaultInterventions,
        experiments: experiments ?? defaultExperiments,
        safety: safety,
        formulation: formulation,
        defaults: defaults,
        relapsePreventionCard: relapsePreventionCard
    )
}

// MARK: - Pipeline Tests

@Suite("ValidationPipeline")
struct ValidationPipelineTests {

    // MARK: - Valid protocols

    @Test("Valid protocol passes all checks")
    func validProtocolPasses() {
        let result = ValidationPipeline.validate(makeValidProtocol())
        #expect(result.isValid)
        #expect(result.errors.isEmpty)
    }

    @Test("Valid protocol with all optional fields empty passes")
    func validProtocolMinimalPasses() {
        let proto = makeValidProtocol(
            whenToUse: ["Anxious"],
            hotThoughtTemplates: [],
            defaults: nil,
            relapsePreventionCard: nil
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.isValid)
    }

    @Test("Valid protocol with all optional fields populated passes")
    func validProtocolFullPasses() {
        let proto = makeValidProtocol(
            defaults: ProtocolDefaults(
                defaultEmotionIntensity: 50,
                defaultBeliefStrength: 70,
                recommendedInterventionID: "be-prediction-test"
            ),
            relapsePreventionCard: RelapsePreventionCard(
                keyTrigger: "Work stress",
                updatedBelief: "Mistakes are normal",
                bestInterventionID: "be-prediction-test",
                bestInterventionTitle: "Prediction Test",
                summaryNote: "This worked well"
            )
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.isValid)
    }

    @Test("Unicode characters in text fields pass validation")
    func unicodeTextPasses() {
        let proto = makeValidProtocol(
            name: "Protocole d'anxiété 日本語テスト",
            summary: "Résumé avec accents éèê et émojis"
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.isValid)
    }

    // MARK: - Schema validation

    @Test("Missing name produces missingRequired error")
    func missingName() {
        let proto = makeValidProtocol(name: "")
        let result = ValidationPipeline.validate(proto)
        #expect(!result.isValid)
        #expect(result.errors.contains { $0.fieldPath == "name" && $0.errorType == .missingRequired })
    }

    @Test("Whitespace-only name is treated as empty")
    func whitespaceOnlyName() {
        let proto = makeValidProtocol(name: "   ")
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "name" && $0.errorType == .missingRequired })
    }

    @Test("Missing summary produces error")
    func missingSummary() {
        let proto = makeValidProtocol(summary: "")
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "summary" && $0.errorType == .missingRequired })
    }

    @Test("Empty interventions array produces error")
    func emptyInterventions() {
        let proto = makeValidProtocol(interventions: [])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "interventions" && $0.errorType == .missingRequired })
    }

    @Test("Empty safety message produces error")
    func emptySafetyMessage() {
        let proto = makeValidProtocol(safety: SafetyInfo(message: "", resources: SafetyResource.ukDefaults))
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "safety.message" && $0.errorType == .missingRequired })
    }

    @Test("Empty safety resources produces error")
    func emptySafetyResources() {
        let proto = makeValidProtocol(safety: SafetyInfo(message: "Call for help", resources: []))
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "safety.resources" && $0.errorType == .missingRequired })
    }

    @Test("Empty target belief produces error")
    func emptyTargetBelief() {
        let proto = makeValidProtocol(targets: ProtocolTargets(targetBelief: ""))
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "targets.targetBelief" && $0.errorType == .missingRequired })
    }

    @Test("Experiment missing prediction produces error")
    func experimentMissingPrediction() {
        let experiment = Experiment(prediction: "", steps: ["Do it"], measures: ["anxiety"], successCriteria: "It worked")
        let proto = makeValidProtocol(experiments: [experiment])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "experiments[0].prediction" && $0.errorType == .missingRequired })
    }

    @Test("Experiment missing steps produces error")
    func experimentMissingSteps() {
        let experiment = Experiment(prediction: "Bad things", steps: [], measures: ["anxiety"], successCriteria: "It worked")
        let proto = makeValidProtocol(experiments: [experiment])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "experiments[0].steps" && $0.errorType == .missingRequired })
    }

    @Test("Experiment missing success criteria produces error")
    func experimentMissingSuccessCriteria() {
        let experiment = Experiment(prediction: "Bad things", steps: ["Do it"], measures: ["anxiety"], successCriteria: "")
        let proto = makeValidProtocol(experiments: [experiment])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "experiments[0].successCriteria" && $0.errorType == .missingRequired })
    }

    // MARK: - Constraint validation

    @Test("Script over 240 chars produces constraintViolation")
    func scriptTooLong() {
        let longScript = String(repeating: "a", count: 241)
        let intervention = InterventionInstance(
            interventionID: "be-prediction-test",
            type: .behaviouralExperiment,
            title: "Test",
            script: longScript,
            durationEstimate: 60
        )
        let proto = makeValidProtocol(interventions: [intervention])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "interventions[0].script" && $0.errorType == .constraintViolation })
    }

    @Test("Script exactly 240 chars passes")
    func scriptExactlyMaxLength() {
        let script = String(repeating: "a", count: 240)
        let intervention = InterventionInstance(
            interventionID: "be-prediction-test",
            type: .behaviouralExperiment,
            title: "Test",
            script: script,
            durationEstimate: 60
        )
        let proto = makeValidProtocol(interventions: [intervention])
        let result = ValidationPipeline.validate(proto)
        let scriptErrors = result.errors.filter { $0.fieldPath == "interventions[0].script" }
        #expect(scriptErrors.isEmpty)
    }

    @Test("whenToUse entry over 80 chars produces error")
    func whenToUseTooLong() {
        let longEntry = String(repeating: "x", count: 81)
        let proto = makeValidProtocol(whenToUse: [longEntry])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "whenToUse[0]" && $0.errorType == .constraintViolation })
    }

    @Test("whenToUse entry exactly 80 chars passes")
    func whenToUseExactlyMaxLength() {
        let entry = String(repeating: "x", count: 80)
        let proto = makeValidProtocol(whenToUse: [entry])
        let result = ValidationPipeline.validate(proto)
        let whenErrors = result.errors.filter { $0.fieldPath == "whenToUse[0]" }
        #expect(whenErrors.isEmpty)
    }

    @Test("Invalid interventionID produces invalidReference error")
    func invalidInterventionID() {
        let intervention = InterventionInstance(
            interventionID: "nonexistent-id",
            type: .behaviouralExperiment,
            title: "Test",
            script: "Do the thing",
            durationEstimate: 60
        )
        let proto = makeValidProtocol(interventions: [intervention])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains { $0.fieldPath == "interventions[0].interventionID" && $0.errorType == .invalidReference })
    }

    @Test("Invalid relapsePreventionCard.bestInterventionID produces error")
    func invalidRelapseCardID() {
        let proto = makeValidProtocol(
            relapsePreventionCard: RelapsePreventionCard(
                keyTrigger: "Stress",
                updatedBelief: "It's fine",
                bestInterventionID: "bogus-id",
                bestInterventionTitle: "Bogus",
                summaryNote: "N/A"
            )
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "relapsePreventionCard.bestInterventionID" && $0.errorType == .invalidReference
        })
    }

    @Test("Invalid defaults.recommendedInterventionID produces error")
    func invalidDefaultsRecommendedID() {
        let proto = makeValidProtocol(
            defaults: ProtocolDefaults(recommendedInterventionID: "bad-id")
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "defaults.recommendedInterventionID" && $0.errorType == .invalidReference
        })
    }

    @Test("defaultEmotionIntensity outside 0-100 produces error")
    func emotionIntensityOutOfRange() {
        let proto = makeValidProtocol(
            defaults: ProtocolDefaults(defaultEmotionIntensity: 150)
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "defaults.defaultEmotionIntensity" && $0.errorType == .constraintViolation
        })
    }

    @Test("defaultBeliefStrength below 0 produces error")
    func beliefStrengthNegative() {
        let proto = makeValidProtocol(
            defaults: ProtocolDefaults(defaultBeliefStrength: -1)
        )
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "defaults.defaultBeliefStrength" && $0.errorType == .constraintViolation
        })
    }

    @Test("Invalid maintainingCycle targetInterventionID produces error")
    func invalidMaintainingCycleID() {
        let formulation = Formulation(maintainingCycles: [
            MaintainingCycle(
                behaviour: .rumination,
                shortTermFunction: "Feels productive",
                longTermCost: "More anxiety",
                targetInterventionID: "fake-id"
            )
        ])
        let proto = makeValidProtocol(formulation: formulation)
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "formulation.maintainingCycles[0].targetInterventionID" && $0.errorType == .invalidReference
        })
    }

    // MARK: - Content policy

    @Test("Medical dosage language produces contentPolicy error")
    func medicalDosageInScript() {
        let intervention = InterventionInstance(
            interventionID: "be-prediction-test",
            type: .behaviouralExperiment,
            title: "Test",
            script: "Please prescribe 20mg of medication",
            durationEstimate: 60
        )
        let proto = makeValidProtocol(interventions: [intervention])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "interventions[0].script" && $0.errorType == .contentPolicy
        })
    }

    @Test("Benign text produces no content policy error")
    func benignTextPasses() {
        let proto = makeValidProtocol()
        let result = ValidationPipeline.validate(proto)
        let policyErrors = result.errors.filter { $0.errorType == .contentPolicy }
        #expect(policyErrors.isEmpty)
    }

    // MARK: - Combined

    @Test("Multiple errors from all validators are reported together")
    func multipleErrorsCombined() {
        let longScript = String(repeating: "a", count: 300)
        let intervention = InterventionInstance(
            interventionID: "nonexistent",
            type: .behaviouralExperiment,
            title: "Test",
            script: longScript,
            durationEstimate: 0
        )
        let proto = CBTProtocol(
            name: "",
            summary: "",
            targets: ProtocolTargets(targetBelief: ""),
            interventions: [intervention],
            safety: SafetyInfo(message: "", resources: [])
        )
        let result = ValidationPipeline.validate(proto)
        #expect(!result.isValid)

        // Should have errors from schema (name, summary, safety.message, safety.resources, targetBelief)
        // and from constraints (script length, invalid ID, duration)
        #expect(result.errors.count >= 7)

        let errorTypes = Set(result.errors.map(\.errorType))
        #expect(errorTypes.contains(.missingRequired))
        #expect(errorTypes.contains(.constraintViolation))
        #expect(errorTypes.contains(.invalidReference))
    }

    @Test("Zero-duration intervention produces constraint error")
    func zeroDurationIntervention() {
        let intervention = InterventionInstance(
            interventionID: "be-prediction-test",
            type: .behaviouralExperiment,
            title: "Test",
            script: "Do the thing",
            durationEstimate: 0
        )
        let proto = makeValidProtocol(interventions: [intervention])
        let result = ValidationPipeline.validate(proto)
        #expect(result.errors.contains {
            $0.fieldPath == "interventions[0].durationEstimate" && $0.errorType == .constraintViolation
        })
    }
}
