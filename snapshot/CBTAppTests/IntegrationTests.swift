import XCTest
import SwiftData
@testable import Domain
@testable import Data

/// Integration tests verifying end-to-end flows with in-memory SwiftData.
/// Tests use real SwiftData repositories to verify persistence works correctly.
@MainActor
final class IntegrationTests: XCTestCase {

    // MARK: - Helpers

    private func makeContainer() throws -> ModelContainer {
        try DataContainer.makeInMemoryContainer()
    }

    private func makeRepos(container: ModelContainer) -> (
        protocolRepo: SwiftDataProtocolRepository,
        runRepo: SwiftDataRunRepository,
        measureRepo: SwiftDataMeasureRepository
    ) {
        (
            SwiftDataProtocolRepository(modelContainer: container),
            SwiftDataRunRepository(modelContainer: container),
            SwiftDataMeasureRepository(modelContainer: container)
        )
    }

    // MARK: - Test 1: Protocol saved to SwiftData and loadable

    func testNewProtocolSavedAndLoadable() async throws {
        let container = try makeContainer()
        let (protocolRepo, _, _) = makeRepos(container: container)

        let proto = SampleData.lateNightRumination
        try await protocolRepo.save(proto)

        // Verify it can be fetched by ID
        let fetched = try await protocolRepo.fetch(id: proto.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, proto.name)
        XCTAssertEqual(fetched?.interventions.count, proto.interventions.count)

        // Verify it appears in fetchAll
        let all = try await protocolRepo.fetchAll(status: .active)
        XCTAssertTrue(all.contains { $0.id == proto.id })
    }

    // MARK: - Test 2: Completed run persists and is queryable

    func testRunSavedAndQueryable() async throws {
        let container = try makeContainer()
        let (protocolRepo, runRepo, _) = makeRepos(container: container)

        let proto = SampleData.lateNightRumination
        try await protocolRepo.save(proto)

        // Create and save a completed run
        var run = Run(protocolID: proto.id, protocolVersion: proto.version)
        run.situation = "Lying in bed, can't sleep"
        run.hotThought = "I'll never be good enough"
        run.emotions = [EmotionRating(emotion: .anxiety, intensity: 80)]
        run.emotionsAfter = [EmotionRating(emotion: .anxiety, intensity: 45)]
        run.beliefStrengthBefore = 85
        run.beliefStrengthAfter = 50
        run.completionStatus = .completed
        run.timestampEnd = Date()
        try await runRepo.save(run)

        // Verify run is persisted
        let fetchedRun = try await runRepo.fetch(id: run.id)
        XCTAssertNotNil(fetchedRun)
        XCTAssertEqual(fetchedRun?.completionStatus, .completed)
        XCTAssertEqual(fetchedRun?.situation, "Lying in bed, can't sleep")

        // Verify completed count
        let completedCount = try await runRepo.completedRunCount(forProtocolID: proto.id)
        XCTAssertEqual(completedCount, 1)

        // Verify belief strength trend
        let trend = try await runRepo.beliefStrengthTrend(forProtocolID: proto.id)
        XCTAssertEqual(trend.count, 1)
        XCTAssertEqual(trend.first?.before, 85)
        XCTAssertEqual(trend.first?.after, 50)

        // Verify DashboardStats calculation
        let runs = try await runRepo.fetchRuns(forProtocolID: proto.id)
        let stats = DashboardStatsCalculator.calculate(from: runs)
        XCTAssertEqual(stats.completedRunCount, 1)
    }

    // MARK: - Test 3: Protocol revision saves new version

    func testProtocolRevisionSavesNewVersion() async throws {
        let container = try makeContainer()
        let (protocolRepo, _, _) = makeRepos(container: container)

        let original = SampleData.workPerfectionism
        try await protocolRepo.save(original)

        // Revise protocol
        var revised = original
        revised.name = "Work Perfectionism (Revised)"
        revised.version = "2.0"
        revised.updatedAt = Date()
        try await protocolRepo.save(revised)

        // Fetch and verify revision was applied
        let fetched = try await protocolRepo.fetch(id: original.id)
        XCTAssertEqual(fetched?.name, "Work Perfectionism (Revised)")
        XCTAssertEqual(fetched?.version, "2.0")

        // Should still be 1 protocol, not 2 (update-in-place)
        let count = try await protocolRepo.count(status: nil)
        XCTAssertEqual(count, 1)
    }

    // MARK: - Test 4: Quick Triage returns correct protocol from SwiftData

    func testQuickTriageFindsMatchingProtocol() async throws {
        let container = try makeContainer()
        let (protocolRepo, _, _) = makeRepos(container: container)

        for proto in SampleData.allProtocols {
            try await protocolRepo.save(proto)
        }

        let allProtocols = try await protocolRepo.fetchAll(status: nil)

        let answers = TriageAnswers(
            urge: .ruminate,
            theme: .comparison,
            intensity: 70
        )
        let matches = TriageMatcher.match(answers: answers, protocols: allProtocols)
        XCTAssertFalse(matches.isEmpty, "Triage should find at least one matching protocol")
    }

    // MARK: - Test 5: SafetySystem evaluates escalation

    func testEscalationEvaluationWithMockSafetySystem() async throws {
        let safetySystem = MockSafetySystem()
        safetySystem.chronicNonResponseResult = SafetyAlert(
            kind: .chronicNonResponse,
            message: "Scores are worsening over time.",
            resources: SafetyResource.ukDefaults,
            canContinue: true
        )

        let scores = (0..<4).map { i in
            MeasureScore(
                date: Calendar.current.date(byAdding: .weekOfYear, value: -3 + i, to: Date())!,
                totalScore: 10 + (i * 4),
                itemResponses: Array(repeating: 2, count: 9)
            )
        }

        let alert = safetySystem.evaluateChronicNonResponse(scores: scores)
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.kind, .chronicNonResponse)
        XCTAssertEqual(safetySystem.chronicNonResponseCallCount, 1)
    }

    // MARK: - Test 6: Seed data populates empty store

    func testSeedDataPopulatesEmptyStore() async throws {
        let container = try makeContainer()
        let (protocolRepo, _, _) = makeRepos(container: container)

        let initialCount = try await protocolRepo.count(status: nil)
        XCTAssertEqual(initialCount, 0)

        for proto in SampleData.allProtocols {
            try await protocolRepo.save(proto)
        }

        let finalCount = try await protocolRepo.count(status: nil)
        XCTAssertEqual(finalCount, SampleData.allProtocols.count)

        for proto in SampleData.allProtocols {
            let fetched = try await protocolRepo.fetch(id: proto.id)
            XCTAssertNotNil(fetched)
            XCTAssertEqual(fetched?.name, proto.name)
        }
    }

    // MARK: - Test 7: Delete protocol cascades to runs

    func testDeleteProtocolCascadesToRuns() async throws {
        let container = try makeContainer()
        let (protocolRepo, runRepo, _) = makeRepos(container: container)

        let proto = SampleData.comparisonScrolling
        try await protocolRepo.save(proto)

        for _ in 0..<3 {
            var run = Run(protocolID: proto.id, protocolVersion: proto.version)
            run.completionStatus = .completed
            run.timestampEnd = Date()
            try await runRepo.save(run)
        }

        let runCount = try await runRepo.completedRunCount(forProtocolID: proto.id)
        XCTAssertEqual(runCount, 3)

        try await runRepo.deleteRuns(forProtocolID: proto.id)
        try await protocolRepo.delete(id: proto.id)

        let remainingRuns = try await runRepo.fetchRuns(forProtocolID: proto.id)
        XCTAssertTrue(remainingRuns.isEmpty)

        let remainingProtocol = try await protocolRepo.fetch(id: proto.id)
        XCTAssertNil(remainingProtocol)
    }

    // MARK: - Test 8: Measure scores persist and retrieve

    func testMeasureScoresPersistAndRetrieve() async throws {
        let container = try makeContainer()
        let (_, _, measureRepo) = makeRepos(container: container)

        let score1 = MeasureScore(
            date: Date().addingTimeInterval(-86400 * 7),
            totalScore: 12,
            itemResponses: [2, 1, 2, 1, 1, 2, 1, 1, 1]
        )
        let score2 = MeasureScore(
            date: Date(),
            totalScore: 8,
            itemResponses: [1, 1, 1, 1, 0, 2, 1, 0, 1]
        )

        try await measureRepo.saveScore(score1, measureID: "PHQ-9")
        try await measureRepo.saveScore(score2, measureID: "PHQ-9")

        let scores = try await measureRepo.fetchScores(measureID: "PHQ-9")
        XCTAssertEqual(scores.count, 2)

        let latest = try await measureRepo.latestScore(measureID: "PHQ-9")
        XCTAssertNotNil(latest)
        XCTAssertEqual(latest?.totalScore, 8)
    }
}
