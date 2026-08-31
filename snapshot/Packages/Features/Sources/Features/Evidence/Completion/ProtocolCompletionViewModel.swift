import Foundation
import Domain
import Utilities

/// Drives the protocol completion flow with learning note and relapse prevention card.
@Observable
@MainActor
public final class ProtocolCompletionViewModel: ProtocolCompletionViewModelProtocol {

    // MARK: - Dependencies

    private let initialProtocol: CBTProtocol
    private let protocolRepository: any ProtocolRepositoryProtocol
    private let logger: ModuleLogger

    // MARK: - Published state

    public let candidate: CompletionCandidate
    public var learningNote: String = ""
    public var relapseCard: RelapsePreventionCard?
    public var isCompleted: Bool = false

    // MARK: - Init

    public nonisolated init(
        cbtProtocol: CBTProtocol,
        candidate: CompletionCandidate,
        protocolRepository: any ProtocolRepositoryProtocol,
        logger: ModuleLogger = CBTLogger.logger(for: .evidence)
    ) {
        self.initialProtocol = cbtProtocol
        self.candidate = candidate
        self.protocolRepository = protocolRepository
        self.logger = logger
    }

    // MARK: - Actions

    public func completeProtocol() async {
        let correlationID = String(initialProtocol.id.uuidString.prefix(8).lowercased())
        logger.debug("Completing protocol: \(initialProtocol.name)", correlationID: correlationID)

        // Build relapse prevention card from candidate suggestions
        let card = RelapsePreventionCard(
            keyTrigger: candidate.suggestedKeyTrigger ?? initialProtocol.whenToUse.first ?? "",
            updatedBelief: candidate.suggestedUpdatedBelief ?? initialProtocol.targets.targetBelief,
            bestInterventionID: candidate.suggestedBestInterventionID ?? "",
            bestInterventionTitle: candidate.suggestedBestInterventionTitle ?? "",
            summaryNote: learningNote
        )
        relapseCard = card

        // Build updated protocol
        var updated = initialProtocol
        updated.status = .completed
        updated.completionSummary = learningNote
        updated.relapsePreventionCard = card
        updated.updatedAt = Date()

        do {
            try await protocolRepository.save(updated)
            isCompleted = true
            logger.info("Protocol completed: \(initialProtocol.name)", correlationID: correlationID)
        } catch {
            logger.error("Failed to complete protocol: \(error.localizedDescription)", correlationID: correlationID)
        }
    }
}
