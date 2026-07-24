import Foundation

/// Pure-function logic for progressive formulation assembly during the workshop.
///
/// Each stage contributes data to the formulation:
/// - Stage 1: Creates TriggerAppraisalLink (with empty appraisal)
/// - Stage 3: Adds MaintainingCycle entries
/// - Stage 4: Fills in the appraisal (target belief)
/// - Stage 5: Links interventions to maintaining cycles
public enum FormulationBuilder {

    /// Create an initial formulation from Stage 1 capture data.
    ///
    /// The appraisal is left empty — it will be filled in Stage 4
    /// after guided discovery of the target belief.
    public static func fromCapture(
        situation: String,
        emotion: EmotionType,
        urge: UrgeType
    ) -> Formulation {
        let link = TriggerAppraisalLink(
            trigger: situation,
            appraisal: "",
            emotion: emotion,
            behaviour: urge
        )
        return Formulation(triggerAppraisalLinks: [link])
    }

    /// Add maintaining cycles from Stage 3 guided discovery.
    ///
    /// Deduplicates by behaviour type — if a cycle with the same type
    /// already exists, it is not added again.
    public static func addMaintainingCycles(
        to formulation: Formulation,
        behaviours: [MaintainingBehaviour]
    ) -> Formulation {
        var updated = formulation
        let existingTypes = Set(updated.maintainingCycles.map(\.behaviour))

        for behaviour in behaviours {
            guard !existingTypes.contains(behaviour.type) else { continue }
            let cycle = MaintainingCycle(
                behaviour: behaviour.type,
                shortTermFunction: behaviour.shortTermRelief,
                longTermCost: behaviour.longTermCost
            )
            updated.maintainingCycles.append(cycle)
        }
        return updated
    }

    /// Set the appraisal (target belief) on the first trigger-appraisal link.
    ///
    /// Called after Stage 4 guided discovery identifies the core belief.
    public static func setAppraisal(
        in formulation: Formulation,
        targetBelief: String
    ) -> Formulation {
        var updated = formulation
        if !updated.triggerAppraisalLinks.isEmpty {
            updated.triggerAppraisalLinks[0].appraisal = targetBelief
        }
        return updated
    }

    /// Link an intervention to a maintaining cycle by matching cycle ID.
    public static func linkIntervention(
        in formulation: Formulation,
        cycleID: UUID,
        interventionID: String
    ) -> Formulation {
        var updated = formulation
        if let index = updated.maintainingCycles.firstIndex(where: { $0.id == cycleID }) {
            updated.maintainingCycles[index].targetInterventionID = interventionID
        }
        return updated
    }
}
