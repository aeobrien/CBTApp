import Foundation
import Domain
import Utilities

/// Drives the protocol dashboard, computing stats from run and measure data.
@Observable
@MainActor
public final class ProtocolDashboardViewModel: ProtocolDashboardViewModelProtocol {

    // MARK: - Dependencies

    private let cbtProtocol: CBTProtocol
    private let runRepository: any RunRepositoryProtocol
    private let measureRepository: any MeasureRepositoryProtocol
    private let logger: ModuleLogger

    // MARK: - Published state

    public var stats: DashboardStats?
    public var isLoading: Bool = false
    public var measureScores: [String: [MeasureScore]] = [:]
    public var completionCandidate: CompletionCandidate?

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

    public func loadDashboard() async {
        let correlationID = String(cbtProtocol.id.uuidString.prefix(8).lowercased())
        logger.debug("Loading dashboard for protocol: \(cbtProtocol.name)", correlationID: correlationID)
        isLoading = true

        do {
            let runs = try await runRepository.fetchRuns(forProtocolID: cbtProtocol.id)
            stats = DashboardStatsCalculator.calculate(from: runs)

            // Load measure scores
            for measure in cbtProtocol.standardisedMeasures {
                let scores = try await measureRepository.fetchScores(measureID: measure.measureID)
                measureScores[measure.measureID] = scores
            }

            // Check completion candidate
            completionCandidate = CompletionDetector.evaluate(cbtProtocol: cbtProtocol, runs: runs)

            logger.info("Dashboard loaded: \(runs.count) runs, \(measureScores.count) measures", correlationID: correlationID)
        } catch {
            logger.error("Failed to load dashboard: \(error.localizedDescription)", correlationID: correlationID)
        }

        isLoading = false
    }
}
