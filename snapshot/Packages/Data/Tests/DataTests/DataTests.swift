import Testing
import Foundation
import SwiftData
@testable import Data
@testable import Domain

@Suite("PersistedProtocol")
struct PersistedProtocolTests {

    @Test("Create from Domain type and convert back")
    func roundTrip() throws {
        let original = SampleData.lateNightRumination
        let persisted = try PersistedProtocol(from: original)
        let converted = try persisted.toDomain()

        #expect(converted.name == original.name)
        #expect(converted.summary == original.summary)
        #expect(converted.status == original.status)
        #expect(converted.whenToUse == original.whenToUse)
        #expect(converted.hotThoughtTemplates == original.hotThoughtTemplates)
        #expect(converted.interventions.count == original.interventions.count)
        #expect(converted.experiments.count == original.experiments.count)
        #expect(converted.tags == original.tags)
    }

    @Test("Searchable text contains name, triggers, and hot thoughts")
    func searchableText() throws {
        let p = SampleData.lateNightRumination
        let persisted = try PersistedProtocol(from: p)

        #expect(persisted.searchableText.contains("late-night rumination"))
        #expect(persisted.searchableText.contains("lying in bed"))
        #expect(persisted.searchableText.contains("i should have said"))
    }

    @Test("Update preserves changes")
    func updateFromDomain() throws {
        var p = SampleData.lateNightRumination
        let persisted = try PersistedProtocol(from: p)

        p.name = "Updated name"
        p.status = .paused
        try persisted.update(from: p)

        #expect(persisted.name == "Updated name")
        #expect(persisted.statusRaw == "paused")

        let converted = try persisted.toDomain()
        #expect(converted.name == "Updated name")
        #expect(converted.status == .paused)
    }
}

@Suite("PersistedRun")
struct PersistedRunTests {

    @Test("Create from Domain type and convert back")
    func roundTrip() throws {
        let runs = SampleData.sampleRuns(forProtocolID: SampleData.lateNightRumination.id, count: 1)
        let original = runs[0]
        let persisted = try PersistedRun(from: original)
        let converted = try persisted.toDomain()

        #expect(converted.protocolID == original.protocolID)
        #expect(converted.completionStatus == original.completionStatus)
        #expect(converted.emotions.count == original.emotions.count)
        #expect(converted.outcomeTags == original.outcomeTags)
    }

    @Test("Update preserves changes")
    func updateFromDomain() throws {
        var run = Run(protocolID: UUID(), completionStatus: .abandoned)
        let persisted = try PersistedRun(from: run)

        run.completionStatus = .completed
        run.timestampEnd = Date()
        try persisted.update(from: run)

        #expect(persisted.completionStatusRaw == "completed")
        #expect(persisted.timestampEnd != nil)
    }
}

@Suite("PersistedMeasureScore")
struct PersistedMeasureScoreTests {

    @Test("Create from Domain type and convert back")
    func roundTrip() throws {
        let score = MeasureScore(totalScore: 14, itemResponses: [2, 1, 3, 0, 2, 1, 2, 1, 2])
        let persisted = try PersistedMeasureScore(from: score, measureID: "PHQ-9")
        let converted = try persisted.toDomain()

        #expect(converted.totalScore == 14)
        #expect(converted.itemResponses?.count == 9)
        #expect(persisted.measureID == "PHQ-9")
    }

    @Test("Score without item responses round-trips")
    func noItemResponses() throws {
        let score = MeasureScore(totalScore: 8)
        let persisted = try PersistedMeasureScore(from: score, measureID: "GAD-7")
        let converted = try persisted.toDomain()

        #expect(converted.totalScore == 8)
        #expect(converted.itemResponses == nil)
    }
}

@Suite("DataContainer")
struct DataContainerTests {

    @Test("In-memory container creates successfully")
    func inMemoryContainer() throws {
        let container = try DataContainer.makeInMemoryContainer()
        #expect(container.schema.entities.count > 0)
    }
}
