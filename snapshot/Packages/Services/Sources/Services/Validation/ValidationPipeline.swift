import Domain
import Utilities

/// The public API for validating a CBTProtocol.
///
/// Composes schema, constraint, and content policy validators.
/// Returns structured errors suitable for agent repair feedback.
public enum ValidationPipeline {

    private static let logger = CBTLogger.logger(for: .validation)

    /// Validate a protocol against all rules.
    public static func validate(_ protocol: CBTProtocol) -> ValidationResult {
        logger.debug("Starting validation for protocol '\(`protocol`.name)'")

        var errors: [ValidationError] = []
        errors += SchemaValidator.validate(`protocol`)
        errors += ConstraintValidator.validate(`protocol`)
        errors += ContentPolicyValidator.validate(`protocol`)

        let result = ValidationResult(errors: errors)

        if result.isValid {
            logger.info("Validation passed for protocol '\(`protocol`.name)'")
        } else {
            logger.info("Validation failed for protocol '\(`protocol`.name)' — \(errors.count) error(s)")
            for error in errors {
                logger.debug("  [\(error.fieldPath)] \(error.errorType.rawValue): \(error.message)")
            }
        }

        return result
    }
}
