import Foundation
import SwiftData
import Domain

/// SwiftData implementation of RunRepositoryProtocol.
@ModelActor
public actor SwiftDataRunRepository: RunRepositoryProtocol {

    public func fetchRuns(forProtocolID protocolID: UUID) async throws -> [Run] {
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.protocolID == protocolID },
            sortBy: [SortDescriptor(\.timestampStart, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func fetchRuns(from startDate: Date, to endDate: Date) async throws -> [Run] {
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.timestampStart >= startDate && $0.timestampStart <= endDate },
            sortBy: [SortDescriptor(\.timestampStart, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func fetch(id: UUID) async throws -> Run? {
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.runID == id }
        )
        guard let persisted = try modelContext.fetch(descriptor).first else { return nil }
        return try persisted.toDomain()
    }

    public func fetchRecent(limit: Int) async throws -> [Run] {
        var descriptor = FetchDescriptor<PersistedRun>(
            sortBy: [SortDescriptor(\.timestampStart, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func save(_ run: Run) async throws {
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.runID == run.id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            try existing.update(from: run)
        } else {
            let persisted = try PersistedRun(from: run)
            modelContext.insert(persisted)
        }
        try modelContext.save()
    }

    public func deleteRuns(forProtocolID protocolID: UUID) async throws {
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.protocolID == protocolID }
        )
        let runs = try modelContext.fetch(descriptor)
        for run in runs {
            modelContext.delete(run)
        }
        if !runs.isEmpty {
            try modelContext.save()
        }
    }

    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.runID == id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    public func completedRunCount(forProtocolID protocolID: UUID) async throws -> Int {
        let completedRaw = RunCompletionStatus.completed.rawValue
        let descriptor = FetchDescriptor<PersistedRun>(
            predicate: #Predicate { $0.protocolID == protocolID && $0.completionStatusRaw == completedRaw }
        )
        return try modelContext.fetchCount(descriptor)
    }

    public func averageEmotionChange(forProtocolID protocolID: UUID) async throws -> Double? {
        let runs = try await fetchRuns(forProtocolID: protocolID)
        let changes = runs.compactMap(\.emotionChange)
        guard !changes.isEmpty else { return nil }
        return changes.reduce(0, +) / Double(changes.count)
    }

    public func beliefStrengthTrend(forProtocolID protocolID: UUID) async throws -> [(date: Date, before: Int, after: Int)] {
        let runs = try await fetchRuns(forProtocolID: protocolID)
        return runs.compactMap { run in
            guard let before = run.beliefStrengthBefore,
                  let after = run.beliefStrengthAfter else { return nil }
            return (date: run.timestampStart, before: before, after: after)
        }.sorted { $0.date < $1.date }
    }
}
