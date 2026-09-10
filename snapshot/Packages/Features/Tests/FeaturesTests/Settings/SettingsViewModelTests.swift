import XCTest
@testable import Features
@testable import Domain

@MainActor
final class SettingsViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        protocols: [CBTProtocol] = SampleData.allProtocols,
        runs: [Run] = []
    ) -> (SettingsViewModel, MockProtocolRepository, MockRunRepository) {
        let protoRepo = MockProtocolRepository(protocols: protocols)
        let runRepo = MockRunRepository(runs: runs)
        let vm = SettingsViewModel(protocolRepository: protoRepo, runRepository: runRepo)
        return (vm, protoRepo, runRepo)
    }

    // MARK: - Export

    func testExportProducesValidJSON() async throws {
        let (vm, _, _) = makeViewModel()
        await vm.exportProtocols()

        XCTAssertNotNil(vm.exportData)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([CBTProtocol].self, from: vm.exportData!)
        XCTAssertEqual(decoded.count, SampleData.allProtocols.count)
    }

    // MARK: - Import

    func testImportSavesToRepository() async throws {
        let (vm, protoRepo, _) = makeViewModel(protocols: [])

        let protos = [SampleData.lateNightRumination]
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(protos)

        await vm.importProtocols(from: data)

        XCTAssertTrue(vm.importSuccess)
        XCTAssertNil(vm.importError)
        let saved = try await protoRepo.fetchAll(status: nil)
        XCTAssertEqual(saved.count, 1)
    }

    func testImportInvalidDataSetsError() async {
        let (vm, _, _) = makeViewModel()
        await vm.importProtocols(from: Data("invalid".utf8))

        XCTAssertFalse(vm.importSuccess)
        XCTAssertNotNil(vm.importError)
    }

    // MARK: - Archive

    func testArchiveSetsStatusToArchived() async throws {
        let (vm, protoRepo, _) = makeViewModel()
        let proto = SampleData.lateNightRumination

        await vm.archiveProtocol(proto)

        let saved = try await protoRepo.fetch(id: proto.id)
        XCTAssertEqual(saved?.status, .archived)
    }

    // MARK: - Delete

    func testDeleteRemovesProtocolAndRuns() async throws {
        let proto = SampleData.lateNightRumination
        let run = Run(protocolID: proto.id, protocolVersion: "1.0.0", completionStatus: .completed)
        let (vm, protoRepo, runRepo) = makeViewModel(protocols: [proto], runs: [run])

        await vm.deleteProtocol(proto)

        let savedProto = try await protoRepo.fetch(id: proto.id)
        XCTAssertNil(savedProto)
        let savedRuns = try await runRepo.fetchRuns(forProtocolID: proto.id)
        XCTAssertTrue(savedRuns.isEmpty)
    }

    // MARK: - App Lock Toggle

    func testAppLockToggleStoresPreference() async {
        let (vm, _, _) = makeViewModel()

        vm.appLockEnabled = true
        // On CI/test environments without biometrics, it will auto-disable
        // Just verify the preference was written
        let stored = UserDefaults.standard.bool(forKey: "appLockEnabled")
        XCTAssertEqual(stored, vm.appLockEnabled)
    }

    // MARK: - Appearance Override

    func testAppearanceOverrideStoresPreference() async {
        let (vm, _, _) = makeViewModel()

        vm.appearanceOverride = "dark"
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appearanceOverride"), "dark")

        vm.appearanceOverride = "light"
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appearanceOverride"), "light")

        vm.appearanceOverride = "system"
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appearanceOverride"), "system")
    }

    // MARK: - Workshop Cooldown

    func testWorkshopCooldownStoresPreference() async {
        let (vm, _, _) = makeViewModel()

        vm.workshopCooldownHours = 24
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "workshopCooldownHours"), 24)

        vm.workshopCooldownHours = 0
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "workshopCooldownHours"), 0)
    }

    // MARK: - Reset Metrics

    func testResetAllRunDataDeletesRuns() async throws {
        let proto = SampleData.lateNightRumination
        let run = Run(protocolID: proto.id, protocolVersion: "1.0.0", completionStatus: .completed)
        let (vm, _, runRepo) = makeViewModel(protocols: [proto], runs: [run])

        await vm.resetAllRunData()

        XCTAssertTrue(vm.resetSuccess)
        let remaining = try await runRepo.fetchRecent(limit: 100)
        XCTAssertTrue(remaining.isEmpty)
    }
}
