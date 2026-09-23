import Foundation
import SwiftData
import Domain

/// SwiftData model for persisting Run.
@Model
public final class PersistedRun {

    public var runID: UUID
    public var protocolID: UUID
    public var timestampStart: Date
    public var timestampEnd: Date?
    public var completionStatusRaw: String

    /// The full Run encoded as JSON.
    public var runData: Data

    public init(from run: Run) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.runData = try encoder.encode(run)
        self.runID = run.id
        self.protocolID = run.protocolID
        self.timestampStart = run.timestampStart
        self.timestampEnd = run.timestampEnd
        self.completionStatusRaw = run.completionStatus.rawValue
    }

    /// Convert back to the Domain-layer type.
    public func toDomain() throws -> Run {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Run.self, from: runData)
    }

    /// Update from a Domain-layer type.
    public func update(from run: Run) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.runData = try encoder.encode(run)
        self.runID = run.id
        self.protocolID = run.protocolID
        self.timestampStart = run.timestampStart
        self.timestampEnd = run.timestampEnd
        self.completionStatusRaw = run.completionStatus.rawValue
    }
}
