import Foundation
import Domain
import Utilities

/// Drives the weekly review screen, generating insights from recent data.
@Observable
@MainActor
public final class WeeklyReviewViewModel: WeeklyReviewViewModelProtocol {

    // MARK: - Dependencies

    private let cbtProtocol: CBTProtocol
    private let runRepository: any RunRepositoryProtocol
    private let measureRepository: any MeasureRepositoryProtocol
    private let logger: ModuleLogger

    // MARK: - Published state

    public var insights: [InsightCard] = []
    public var isLoading: Bool = false

    // MARK: - Init

    public nonisolated init(
        cbtProtocol: CBTProtocol,
        runRepository: any RunRepositoryProtocol,
        measureRepository: any MeasureRepositoryProtocol,
        logger: ModuleLogger = CBTLogger.logger(for: .evidence)
    ) {
        self.cbtProtocol = cbtProtocol
        self.runRepository = runRepository
        self.measureRepository = measureRepository
        self.logger = logger
    }

    // MARK: - Load

    public func loadReview() async {
        let correlationID = String(cbtProtocol.id.uuidString.prefix(8).lowercased())
        logger.debug("Loading weekly review", correlationID: correlationID)
        isLoading = true

        do {
            let runs = try await runRepository.fetchRuns(forProtocolID: cbtProtocol.id)

            // Load measure scores
            var scores: [String: [MeasureScore]] = [:]
            for measure in cbtProtocol.standardisedMeasures {
                scores[measure.measureID] = try await measureRepository.fetchScores(measureID: measure.measureID)
            }

            insights = WeeklyReviewGenerator.generate(
                runs: runs,
                cbtProtocol: cbtProtocol,
                measureScores: scores
            )

            logger.info("Weekly review loaded: \(insights.count) insights from \(runs.count) runs", correlationID: correlationID)
        } catch {
            logger.error("Failed to load weekly review: \(error.localizedDescription)", correlationID: correlationID)
        }

        isLoading = false
    }
}
