import Foundation
import SwiftData
import Domain

/// SwiftData implementation of MeasureRepositoryProtocol.
@ModelActor
public actor SwiftDataMeasureRepository: MeasureRepositoryProtocol {

    public func fetchScores(measureID: String) async throws -> [MeasureScore] {
        let descriptor = FetchDescriptor<PersistedMeasureScore>(
            predicate: #Predicate { $0.measureID == measureID },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func fetchScores(measureID: String, from startDate: Date, to endDate: Date) async throws -> [MeasureScore] {
        let descriptor = FetchDescriptor<PersistedMeasureScore>(
            predicate: #Predicate {
                $0.measureID == measureID && $0.date >= startDate && $0.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func saveScore(_ score: MeasureScore, measureID: String) async throws {
        let persisted = try PersistedMeasureScore(from: score, measureID: measureID)
        modelContext.insert(persisted)
        try modelContext.save()
    }

    public func latestScore(measureID: String) async throws -> MeasureScore? {
        var descriptor = FetchDescriptor<PersistedMeasureScore>(
            predicate: #Predicate { $0.measureID == measureID },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.toDomain()
    }
}
