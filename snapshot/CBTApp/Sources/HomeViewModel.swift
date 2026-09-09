import Foundation
import Domain
import Utilities

/// ViewModel for the production home screen.
@Observable
@MainActor
final class HomeViewModel {
    // MARK: - Dependencies
    private let protocolRepository: any ProtocolRepositoryProtocol
    private let runRepository: any RunRepositoryProtocol
    private let logger: ModuleLogger

    // MARK: - State
    var protocols: [CBTProtocol] = []
    var recentRuns: [Run] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Init
    nonisolated init(
        protocolRepository: any ProtocolRepositoryProtocol,
        runRepository: any RunRepositoryProtocol,
        logger: ModuleLogger = CBTLogger.logger(for: .app)
    ) {
        self.protocolRepository = protocolRepository
        self.runRepository = runRepository
        self.logger = logger
    }

    // MARK: - Data Loading

    func loadData() async {
        logger.debug("HomeViewModel.loadData() — loading protocols and recent runs")
        isLoading = true
        errorMessage = nil
        do {
            protocols = try await protocolRepository.fetchAll(status: .active)
            recentRuns = try await runRepository.fetchRecent(limit: 20)
            logger.info("Loaded \(protocols.count) active protocols, \(recentRuns.count) recent runs")
        } catch {
            logger.error("Failed to load home data: \(error.localizedDescription)")
            errorMessage = "Failed to load data. Pull to refresh."
        }
        isLoading = false
    }

    // MARK: - Actions

    func archiveProtocol(_ proto: CBTProtocol) async {
        logger.info("Archiving protocol: \(proto.name) (\(proto.id))")
        var updated = proto
        updated.status = .archived
        updated.updatedAt = Date()
        do {
            try await protocolRepository.save(updated)
            protocols.removeAll { $0.id == proto.id }
        } catch {
            logger.error("Failed to archive protocol: \(error.localizedDescription)")
        }
    }

    func deleteProtocol(_ proto: CBTProtocol) async {
        logger.info("Deleting protocol: \(proto.name) (\(proto.id))")
        do {
            try await runRepository.deleteRuns(forProtocolID: proto.id)
            try await protocolRepository.delete(id: proto.id)
            protocols.removeAll { $0.id == proto.id }
        } catch {
            logger.error("Failed to delete protocol: \(error.localizedDescription)")
        }
    }

    /// Number of completed runs for a given protocol.
    func runCount(for protocolID: UUID) -> Int {
        recentRuns.filter { $0.protocolID == protocolID && $0.completionStatus == .completed }.count
    }

    /// Most recent run date for a given protocol.
    func lastRunDate(for protocolID: UUID) -> Date? {
        recentRuns.first { $0.protocolID == protocolID }?.timestampStart
    }
}
