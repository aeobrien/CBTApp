import Foundation
import SwiftData
import Domain
import os

/// SwiftData implementation of ProtocolRepositoryProtocol.
@ModelActor
public actor SwiftDataProtocolRepository: ProtocolRepositoryProtocol {

    private static let signposter = OSSignposter(subsystem: "com.cbt.app", category: .pointsOfInterest)

    public func fetchAll(status: ProtocolStatus?) async throws -> [CBTProtocol] {
        let signpostState = Self.signposter.beginInterval("FetchAllProtocols")
        defer { Self.signposter.endInterval("FetchAllProtocols", signpostState) }

        var descriptor = FetchDescriptor<PersistedProtocol>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        if let status {
            let statusRaw = status.rawValue
            descriptor.predicate = #Predicate { $0.statusRaw == statusRaw }
        }
        let persisted = try modelContext.fetch(descriptor)
        return try persisted.map { try $0.toDomain() }
    }

    public func fetch(id: UUID) async throws -> CBTProtocol? {
        let descriptor = FetchDescriptor<PersistedProtocol>(
            predicate: #Predicate { $0.protocolID == id }
        )
        guard let persisted = try modelContext.fetch(descriptor).first else { return nil }
        return try persisted.toDomain()
    }

    public func search(query: String) async throws -> [CBTProtocol] {
        let lowered = query.lowercased()
        let descriptor = FetchDescriptor<PersistedProtocol>(
            predicate: #Predicate { $0.searchableText.contains(lowered) },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let persisted = try modelContext.fetch(descriptor)
        return try persisted.map { try $0.toDomain() }
    }

    public func save(_ cbtProtocol: CBTProtocol) async throws {
        let descriptor = FetchDescriptor<PersistedProtocol>(
            predicate: #Predicate { $0.protocolID == cbtProtocol.id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            try existing.update(from: cbtProtocol)
        } else {
            let persisted = try PersistedProtocol(from: cbtProtocol)
            modelContext.insert(persisted)
        }
        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<PersistedProtocol>(
            predicate: #Predicate { $0.protocolID == id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    public func count(status: ProtocolStatus?) async throws -> Int {
        var descriptor = FetchDescriptor<PersistedProtocol>()
        if let status {
            let statusRaw = status.rawValue
            descriptor.predicate = #Predicate { $0.statusRaw == statusRaw }
        }
        return try modelContext.fetchCount(descriptor)
    }
}
