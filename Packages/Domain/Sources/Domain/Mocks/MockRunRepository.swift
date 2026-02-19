import Foundation

/// In-memory mock implementation of RunRepositoryProtocol for testing and previews.
public actor MockRunRepository: RunRepositoryProtocol {
    public var runs: [UUID: Run]

    public init(runs: [Run] = []) {
        self.runs = Dictionary(uniqueKeysWithValues: runs.map { ($0.id, $0) })
    }

    public func fetchRuns(forProtocolID protocolID: UUID) async throws -> [Run] {
        Array(runs.values)
            .filter { $0.protocolID == protocolID }
            .sorted { $0.timestampStart > $1.timestampStart }
    }

    public func fetchRuns(from startDate: Date, to endDate: Date) async throws -> [Run] {
        Array(runs.values)
            .filter { $0.timestampStart >= startDate && $0.timestampStart <= endDate }
            .sorted { $0.timestampStart > $1.timestampStart }
    }

    public func fetch(id: UUID) async throws -> Run? {
        runs[id]
    }

    public func fetchRecent(limit: Int) async throws -> [Run] {
        Array(runs.values)
            .sorted { $0.timestampStart > $1.timestampStart }
            .prefix(limit)
            .map { $0 }
    }

    public func save(_ run: Run) async throws {
        runs[run.id] = run
    }

    public func delete(id: UUID) async throws {
        runs.removeValue(forKey: id)
    }

    public func completedRunCount(forProtocolID protocolID: UUID) async throws -> Int {
        runs.values.filter { $0.protocolID == protocolID && $0.completionStatus == .completed }.count
    }

    public func averageEmotionChange(forProtocolID protocolID: UUID) async throws -> Double? {
        let changes = runs.values
            .filter { $0.protocolID == protocolID }
            .compactMap(\.emotionChange)
        guard !changes.isEmpty else { return nil }
        return changes.reduce(0, +) / Double(changes.count)
    }

    public func beliefStrengthTrend(forProtocolID protocolID: UUID) async throws -> [(date: Date, before: Int, after: Int)] {
        runs.values
            .filter { $0.protocolID == protocolID }
            .compactMap { run in
                guard let before = run.beliefStrengthBefore,
                      let after = run.beliefStrengthAfter else { return nil }
                return (date: run.timestampStart, before: before, after: after)
            }
            .sorted { $0.date < $1.date }
    }
}
