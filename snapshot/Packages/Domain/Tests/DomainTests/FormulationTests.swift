import Testing
import Foundation
@testable import Domain

@Suite("Formulation")
struct FormulationTests {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    @Test("Empty formulation round-trips")
    func emptyFormulation() throws {
        let f = Formulation()
        let data = try encoder.encode(f)
        let decoded = try decoder.decode(Formulation.self, from: data)
        #expect(decoded.triggerAppraisalLinks.isEmpty)
        #expect(decoded.maintainingCycles.isEmpty)
    }

    @Test("Full formulation round-trips")
    func fullFormulation() throws {
        let f = Formulation(
            triggerAppraisalLinks: [
                TriggerAppraisalLink(
                    trigger: "Boss sends late email",
                    appraisal: "I should have replied faster",
                    emotion: .anxiety,
                    behaviour: .ruminate
                )
            ],
            maintainingCycles: [
                MaintainingCycle(
                    behaviour: .rumination,
                    shortTermFunction: "Feels like problem-solving",
                    longTermCost: "Keeps me awake, increases next-day anxiety",
                    targetInterventionID: "delay_01"
                )
            ]
        )

        let data = try encoder.encode(f)
        let decoded = try decoder.decode(Formulation.self, from: data)
        #expect(decoded.triggerAppraisalLinks.count == 1)
        #expect(decoded.triggerAppraisalLinks[0].trigger == "Boss sends late email")
        #expect(decoded.triggerAppraisalLinks[0].emotion == .anxiety)
        #expect(decoded.maintainingCycles.count == 1)
        #expect(decoded.maintainingCycles[0].behaviour == .rumination)
        #expect(decoded.maintainingCycles[0].targetInterventionID == "delay_01")
    }
}
