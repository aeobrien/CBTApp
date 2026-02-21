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
}
