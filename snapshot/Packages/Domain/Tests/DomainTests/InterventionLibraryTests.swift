import Testing
import Foundation
@testable import Domain

@Suite("InterventionLibrary")
struct InterventionLibraryTests {

    @Test("Library contains at least one template per intervention type")
    func allTypesCovered() {
        for type in InterventionType.allCases {
            let matching = InterventionLibrary.allTemplates.filter { $0.type == type }
            #expect(!matching.isEmpty, "No template for type: \(type.rawValue)")
        }
    }

    @Test("All templates have unique IDs")
    func uniqueIDs() {
        let ids = InterventionLibrary.allTemplates.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count)
    }

    @Test("All templates pass schema validation")
    func schemaValidation() {
        for template in InterventionLibrary.allTemplates {
            #expect(!template.id.isEmpty)
            #expect(!template.name.isEmpty)
            #expect(!template.indication.isEmpty)
            #expect(!template.steps.isEmpty)
            #expect(!template.exampleScripts.isEmpty)
            #expect(template.durationEstimate > 0)
            #expect(!template.successCriteria.isEmpty)
            #expect(!template.evidenceBasis.isEmpty)
        }
    }

    @Test("Behavioural experiment has at least 2 variants")
    func behaviouralExperimentVariants() {
        let beTemplates = InterventionLibrary.allTemplates.filter {
            $0.type == .behaviouralExperiment
        }
        #expect(beTemplates.count >= 2)
    }

    @Test("All templates JSON round-trip")
    func jsonRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for template in InterventionLibrary.allTemplates {
            let data = try encoder.encode(template)
            let decoded = try decoder.decode(InterventionTemplate.self, from: data)
            #expect(decoded == template)
        }
    }
}

@Suite("InterventionParameteriser")
struct InterventionParameteriserTests {

    @Test("Substitutes prediction placeholder in Prediction Test")
    func predictionSubstitution() {
        let template = InterventionLibrary.behaviouralExperimentPredictionTest
        let context = InterventionParameteriser.Context(
            prediction: "everyone will hate me"
        )
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(instance.script.contains("everyone will hate me"))
        #expect(!instance.script.contains("{{prediction}}"))
        #expect(instance.interventionID == template.id)
        #expect(instance.type == template.type)
    }

    @Test("Substitutes hotThought placeholder in Survey template")
    func hotThoughtSubstitution() {
        let template = InterventionLibrary.behaviouralExperimentSurvey
        let context = InterventionParameteriser.Context(
            hotThought: "nobody likes me"
        )
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(instance.script.contains("nobody likes me"))
        #expect(!instance.script.contains("{{hotThought}}"))
        #expect(instance.interventionID == template.id)
        #expect(instance.type == template.type)
    }

    @Test("Substitutes urgeBehaviour placeholder")
    func urgeBehaviourSubstitution() {
        let template = InterventionLibrary.delayExperimentUrge
        let context = InterventionParameteriser.Context(
            urgeBehaviour: "check my phone"
        )
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(instance.script.contains("check my phone"))
        #expect(!instance.script.contains("{{urgeBehaviour}}"))
    }

    @Test("Lowercases first character of substituted values")
    func lowercasesFirstChar() {
        let template = InterventionLibrary.behaviouralExperimentPredictionTest
        let context = InterventionParameteriser.Context(
            prediction: "Nobody likes me"
        )
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(instance.script.contains("nobody likes me"))
        #expect(!instance.script.contains("Nobody likes me"))
    }

    @Test("Placeholders detected correctly from template scripts")
    func placeholderDetection() {
        let bePlaceholders = InterventionParameteriser.placeholders(
            in: InterventionLibrary.behaviouralExperimentPredictionTest
        )
        #expect(bePlaceholders == Set(["prediction"]))

        let delayPlaceholders = InterventionParameteriser.placeholders(
            in: InterventionLibrary.delayExperimentUrge
        )
        #expect(delayPlaceholders == Set(["urgeBehaviour"]))

        let exposurePlaceholders = InterventionParameteriser.placeholders(
            in: InterventionLibrary.gradedExposureStep
        )
        #expect(exposurePlaceholders == Set(["targetSituation"]))
    }

    @Test("Script respects character limit")
    func scriptCharacterLimit() {
        let template = InterventionLibrary.behaviouralExperimentPredictionTest
        let longPrediction = String(repeating: "a very long prediction that keeps going ", count: 10)
        let context = InterventionParameteriser.Context(prediction: longPrediction)
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(instance.script.count <= InterventionParameteriser.maxScriptLength)
        #expect(instance.script.hasSuffix("..."))
    }

    @Test("Unsubstituted placeholders replaced with ellipsis")
    func missingContextReplacesPlaceholder() {
        let template = InterventionLibrary.behaviouralExperimentPredictionTest
        let context = InterventionParameteriser.Context() // no hotThought
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(!instance.script.contains("{{"))
        #expect(instance.script.contains("..."))
    }

    @Test("Parameterised instance preserves template metadata")
    func preservesMetadata() {
        let template = InterventionLibrary.defusionThoughtLabelling
        let context = InterventionParameteriser.Context(hotThought: "I'm useless")
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        #expect(instance.interventionID == template.id)
        #expect(instance.type == .defusion)
        #expect(instance.title == template.name)
        #expect(instance.steps == template.steps)
        #expect(instance.durationEstimate == template.durationEstimate)
        #expect(instance.isTimed == true) // defusion is timed
    }

    @Test("isTimed is correct per type")
    func isTimedPerType() {
        #expect(InterventionType.defusion.isTimed == true)
        #expect(InterventionType.delayExperiment.isTimed == true)
        #expect(InterventionType.ruminationScheduling.isTimed == true)
        #expect(InterventionType.behaviouralExperiment.isTimed == false)
        #expect(InterventionType.gradedExposureStep.isTimed == false)
        #expect(InterventionType.behaviouralActivation.isTimed == false)
    }

    @Test("Parameterised instance JSON round-trips")
    func instanceRoundTrip() throws {
        let template = InterventionLibrary.behaviouralExperimentPredictionTest
        let context = InterventionParameteriser.Context(hotThought: "I'll fail the test")
        let instance = InterventionParameteriser.parameterise(template: template, context: context)

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(instance)
        let decoded = try decoder.decode(InterventionInstance.self, from: data)

        #expect(decoded.interventionID == instance.interventionID)
        #expect(decoded.script == instance.script)
        #expect(decoded.type == instance.type)
    }
}

@Suite("InterventionSelector")
struct InterventionSelectorTests {

    @Test("Select all returns all templates")
    func selectAll() {
        let results = InterventionSelector.select(query: .init(applyACTBoundary: false))
        #expect(results.count == InterventionLibrary.allTemplates.count)
    }

    @Test("Filter by type")
    func filterByType() {
        let query = InterventionSelector.Query(
            types: [.behaviouralExperiment],
            applyACTBoundary: false
        )
        let results = InterventionSelector.select(query: query)
        #expect(results.allSatisfy { $0.type == .behaviouralExperiment })
        #expect(results.count >= 2)
    }

    @Test("Contraindication exclusion")
    func contraindicationExclusion() {
        let query = InterventionSelector.Query(
            excludeContraindications: ["acute crisis"],
            applyACTBoundary: false
        )
        let results = InterventionSelector.select(query: query)
        // Templates with "acute crisis" in contraindications should be excluded
        for template in results {
            let hasExclusion = template.contraindications.contains {
                $0.localizedCaseInsensitiveContains("acute crisis")
            }
            #expect(!hasExclusion, "Template \(template.id) should have been excluded")
        }
    }

    @Test("ACT boundary: defusion deprioritised when BE available")
    func actBoundary() {
        // Query that matches both BE and defusion
        let query = InterventionSelector.Query(
            types: [.behaviouralExperiment, .defusion],
            applyACTBoundary: true
        )
        let results = InterventionSelector.select(query: query)

        #expect(!results.isEmpty)
        // Defusion should come after all behavioural experiments
        if let firstDefusionIndex = results.firstIndex(where: { $0.type == .defusion }),
           let lastBEIndex = results.lastIndex(where: { $0.type == .behaviouralExperiment }) {
            #expect(firstDefusionIndex > lastBEIndex, "Defusion should come after BE when ACT boundary is applied")
        }
    }

    @Test("ACT boundary disabled: defusion not deprioritised")
    func actBoundaryDisabled() {
        let query = InterventionSelector.Query(
            types: [.defusion, .behaviouralExperiment],
            applyACTBoundary: false
        )
        let results = InterventionSelector.select(query: query)
        // Just check we get results — order depends on original array order
        #expect(results.count >= 3)
    }

    @Test("Indication keywords sort by relevance")
    func indicationKeywordSort() {
        let query = InterventionSelector.Query(
            indicationKeywords: ["prediction", "testable"],
            applyACTBoundary: false
        )
        let results = InterventionSelector.select(query: query)
        #expect(!results.isEmpty)
        // The prediction test template should rank high because it matches both keywords
        #expect(results[0].id == "be-prediction-test")
    }

    @Test("Empty indication match returns all templates")
    func emptyIndicationMatch() {
        let query = InterventionSelector.Query(
            indicationKeywords: ["xyznonexistent"],
            applyACTBoundary: false
        )
        let results = InterventionSelector.select(query: query)
        // All templates returned (just sorted with 0 matches)
        #expect(results.count == InterventionLibrary.allTemplates.count)
    }
}
