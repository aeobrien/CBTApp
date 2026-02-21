import Foundation

/// Repository for CRUD operations on Runs.
public protocol RunRepositoryProtocol: Sendable {
    /// Fetch all runs for a given protocol, ordered by date descending.
    func fetchRuns(forProtocolID protocolID: UUID) async throws -> [Run]

    /// Fetch runs within a date range.
    func fetchRuns(from startDate: Date, to endDate: Date) async throws -> [Run]

    /// Fetch a single run by ID.
    func fetch(id: UUID) async throws -> Run?

    /// Fetch the N most recent runs across all protocols.
    func fetchRecent(limit: Int) async throws -> [Run]

    /// Save a new run or update an existing one.
    func save(_ run: Run) async throws

    /// Delete a run by ID.
    func delete(id: UUID) async throws

    /// Delete all runs for a given protocol.
    func deleteRuns(forProtocolID protocolID: UUID) async throws

    /// Count completed runs for a given protocol.
    func completedRunCount(forProtocolID protocolID: UUID) async throws -> Int

    /// Calculate average emotion change for a protocol's runs.
    func averageEmotionChange(forProtocolID protocolID: UUID) async throws -> Double?

    /// Fetch belief strength values over time for a protocol.
    func beliefStrengthTrend(forProtocolID protocolID: UUID) async throws -> [(date: Date, before: Int, after: Int)]
}
