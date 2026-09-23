import Domain

/// Validates that all required fields in a CBTProtocol are present and non-empty.
enum SchemaValidator {

    static func validate(_ protocol: CBTProtocol) -> [ValidationError] {
        var errors: [ValidationError] = []

        if `protocol`.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ValidationError(
                fieldPath: "name",
                errorType: .missingRequired,
                message: "Protocol name is required"
            ))
        }

        if `protocol`.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ValidationError(
                fieldPath: "summary",
                errorType: .missingRequired,
                message: "Protocol summary is required"
            ))
        }

        if `protocol`.version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ValidationError(
                fieldPath: "version",
                errorType: .missingRequired,
                message: "Protocol version is required"
            ))
        }

        if `protocol`.interventions.isEmpty {
            errors.append(ValidationError(
                fieldPath: "interventions",
                errorType: .missingRequired,
                message: "At least one intervention is required"
            ))
        }

        if `protocol`.safety.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ValidationError(
                fieldPath: "safety.message",
                errorType: .missingRequired,
                message: "Safety message is required"
            ))
        }

        if `protocol`.safety.resources.isEmpty {
            errors.append(ValidationError(
                fieldPath: "safety.resources",
                errorType: .missingRequired,
                message: "At least one safety resource is required"
            ))
        }

        if `protocol`.targets.targetBelief.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ValidationError(
                fieldPath: "targets.targetBelief",
                errorType: .missingRequired,
                message: "Target belief is required"
            ))
        }

        for (index, experiment) in `protocol`.experiments.enumerated() {
            if experiment.prediction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append(ValidationError(
                    fieldPath: "experiments[\(index)].prediction",
                    errorType: .missingRequired,
                    message: "Experiment prediction is required"
                ))
            }
            if experiment.steps.isEmpty {
                errors.append(ValidationError(
                    fieldPath: "experiments[\(index)].steps",
                    errorType: .missingRequired,
                    message: "Experiment must have at least one step"
                ))
            }
            if experiment.measures.isEmpty {
                errors.append(ValidationError(
                    fieldPath: "experiments[\(index)].measures",
                    errorType: .missingRequired,
                    message: "Experiment must have at least one measure"
                ))
            }
            if experiment.successCriteria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errors.append(ValidationError(
                    fieldPath: "experiments[\(index)].successCriteria",
                    errorType: .missingRequired,
                    message: "Experiment success criteria is required"
                ))
            }
        }

        return errors
    }
}
