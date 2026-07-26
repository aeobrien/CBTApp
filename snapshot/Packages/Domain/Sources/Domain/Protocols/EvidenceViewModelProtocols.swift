import Foundation

/// Testable protocol for the protocol dashboard ViewModel.
@MainActor
public protocol ProtocolDashboardViewModelProtocol: AnyObject {
    var stats: DashboardStats? { get }
    var isLoading: Bool { get }
    var measureScores: [String: [MeasureScore]] { get }
    var completionCandidate: CompletionCandidate? { get }
    func loadDashboard() async
}

/// Testable protocol for the weekly review ViewModel.
@MainActor
public protocol WeeklyReviewViewModelProtocol: AnyObject {
    var insights: [InsightCard] { get }
    var isLoading: Bool { get }
    func loadReview() async
}

/// Testable protocol for the measure administration ViewModel.
@MainActor
public protocol MeasureAdminViewModelProtocol: AnyObject {
    var definition: MeasureDefinition { get }
    var currentItemIndex: Int { get }
    var responses: [Int] { get }
    var isComplete: Bool { get }
    var totalScore: Int { get }
    var scoringBand: ScoringBand? { get }
    var previousScore: MeasureScore? { get }
    func selectResponse(_ value: Int)
    func advance()
    func goBack()
    func submit() async
}

/// Testable protocol for the protocol completion ViewModel.
@MainActor
public protocol ProtocolCompletionViewModelProtocol: AnyObject {
    var candidate: CompletionCandidate { get }
    var learningNote: String { get set }
    var relapseCard: RelapsePreventionCard? { get }
    func completeProtocol() async
}
