import Domain

/// Validates business rules and constraints on a CBTProtocol.
enum ConstraintValidator {

    static func validate(_ protocol: CBTProtocol) -> [ValidationError] {
        var errors: [ValidationError] = []
        let validIDs = Set(InterventionLibrary.allTemplates.map(\.id))

        // whenToUse entries ≤ 80 chars
        for (index, entry) in `protocol`.whenToUse.enumerated() {
            if entry.count > 80 {
                errors.append(ValidationError(
                    fieldPath: "whenToUse[\(index)]",
                    errorType: .constraintViolation,
                    message: "When-to-use entry exceeds 80 characters (\(entry.count))"
                ))
            }
        }

        // Intervention constraints
        for (index, intervention) in `protocol`.interventions.enumerated() {
            if intervention.script.count > InterventionParameteriser.maxScriptLength {
                errors.append(ValidationError(
                    fieldPath: "interventions[\(index)].script",
                    errorType: .constraintViolation,
                    message: "Script exceeds \(InterventionParameteriser.maxScriptLength) characters (\(intervention.script.count))"
                ))
            }

            if !validIDs.contains(intervention.interventionID) {
                errors.append(ValidationError(
                    fieldPath: "interventions[\(index)].interventionID",
                    errorType: .invalidReference,
                    message: "Unknown intervention ID '\(intervention.interventionID)'"
                ))
            }

            if intervention.durationEstimate <= 0 {
                errors.append(ValidationError(
                    fieldPath: "interventions[\(index)].durationEstimate",
                    errorType: .constraintViolation,
                    message: "Duration estimate must be greater than 0"
                ))
            }
        }

        // relapsePreventionCard.bestInterventionID
        if let card = `protocol`.relapsePreventionCard {
            if !validIDs.contains(card.bestInterventionID) {
                errors.append(ValidationError(
                    fieldPath: "relapsePreventionCard.bestInterventionID",
                    errorType: .invalidReference,
                    message: "Unknown intervention ID '\(card.bestInterventionID)'"
                ))
            }
        }

        // formulation.maintainingCycles[*].targetInterventionID
        for (index, cycle) in `protocol`.formulation.maintainingCycles.enumerated() {
            if let targetID = cycle.targetInterventionID, !validIDs.contains(targetID) {
                errors.append(ValidationError(
                    fieldPath: "formulation.maintainingCycles[\(index)].targetInterventionID",
                    errorType: .invalidReference,
                    message: "Unknown intervention ID '\(targetID)'"
                ))
            }
        }

        // defaults
        if let defaults = `protocol`.defaults {
            if let recID = defaults.recommendedInterventionID, !validIDs.contains(recID) {
                errors.append(ValidationError(
                    fieldPath: "defaults.recommendedInterventionID",
                    errorType: .invalidReference,
                    message: "Unknown intervention ID '\(recID)'"
                ))
            }

            if let intensity = defaults.defaultEmotionIntensity, intensity < 0 || intensity > 100 {
                errors.append(ValidationError(
                    fieldPath: "defaults.defaultEmotionIntensity",
                    errorType: .constraintViolation,
                    message: "Emotion intensity must be 0–100 (got \(intensity))"
                ))
            }

            if let strength = defaults.defaultBeliefStrength, strength < 0 || strength > 100 {
                errors.append(ValidationError(
                    fieldPath: "defaults.defaultBeliefStrength",
                    errorType: .constraintViolation,
                    message: "Belief strength must be 0–100 (got \(strength))"
                ))
            }
        }

        return errors
    }
}
