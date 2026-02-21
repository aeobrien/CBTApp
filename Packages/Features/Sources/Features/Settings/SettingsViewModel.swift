import Foundation
import Domain
import Services
import Utilities

/// Drives the Settings screen: API key, export/import, protocol lifecycle.
@Observable
@MainActor
public final class SettingsViewModel {

    // MARK: - Dependencies

    private let protocolRepository: any ProtocolRepositoryProtocol
    private let runRepository: any RunRepositoryProtocol
    private let logger: ModuleLogger

    // MARK: - State

    public var apiKey: String = ""
    public var apiKeySaved: Bool = false
    public var protocols: [CBTProtocol] = []
    public var exportData: Data?
    public var importError: String?
    public var importSuccess: Bool = false

    // MARK: - Init

    public nonisolated init(
        protocolRepository: any ProtocolRepositoryProtocol,
        runRepository: any RunRepositoryProtocol,
        logger: ModuleLogger = CBTLogger.logger(for: .settings)
    ) {
        self.protocolRepository = protocolRepository
        self.runRepository = runRepository
        self.logger = logger
    }

    // MARK: - Load

    public func loadSettings() async {
        apiKey = KeychainHelper.loadAPIKey() ?? ""
        logger.debug("Loaded API key: \(apiKey.isEmpty ? "empty" : "present")")
        await loadProtocols()
    }

    public func loadProtocols() async {
        do {
            protocols = try await protocolRepository.fetchAll(status: nil)
            logger.debug("Loaded \(protocols.count) protocols for settings")
        } catch {
            logger.error("Failed to load protocols: \(error.localizedDescription)")
        }
    }

    // MARK: - API Key

    public func saveAPIKey() {
        do {
            if apiKey.isEmpty {
                KeychainHelper.deleteAPIKey()
                logger.info("API key deleted")
            } else {
                try KeychainHelper.saveAPIKey(apiKey)
                logger.info("API key saved")
            }
            apiKeySaved = true
        } catch {
            logger.error("Failed to save API key: \(error.localizedDescription)")
        }
    }

    // MARK: - Export

    public func exportProtocols() async {
        do {
            let allProtocols = try await protocolRepository.fetchAll(status: nil)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            exportData = try encoder.encode(allProtocols)
            logger.info("Exported \(allProtocols.count) protocols")
        } catch {
            logger.error("Export failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Import

    public func importProtocols(from data: Data) async {
        importError = nil
        importSuccess = false

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let imported = try decoder.decode([CBTProtocol].self, from: data)

            for proto in imported {
                try await protocolRepository.save(proto)
            }

            importSuccess = true
            logger.info("Imported \(imported.count) protocols")
            await loadProtocols()
        } catch {
            importError = error.localizedDescription
            logger.error("Import failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Protocol Lifecycle

    public func archiveProtocol(_ proto: CBTProtocol) async {
        var updated = proto
        updated.status = .archived
        updated.updatedAt = Date()

        do {
            try await protocolRepository.save(updated)
            logger.info("Archived protocol: \(proto.name)")
            await loadProtocols()
        } catch {
            logger.error("Failed to archive protocol: \(error.localizedDescription)")
        }
    }

    public func deleteProtocol(_ proto: CBTProtocol) async {
        do {
            try await runRepository.deleteRuns(forProtocolID: proto.id)
            try await protocolRepository.delete(id: proto.id)
            logger.info("Deleted protocol and runs: \(proto.name)")
            await loadProtocols()
        } catch {
            logger.error("Failed to delete protocol: \(error.localizedDescription)")
        }
    }

    public func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        logger.info("Onboarding reset")
    }

    // MARK: - Preview

    public static func preview() -> SettingsViewModel {
        SettingsViewModel(
            protocolRepository: MockProtocolRepository(protocols: SampleData.allProtocols),
            runRepository: MockRunRepository()
        )
    }
}
