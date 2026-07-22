import SwiftUI
import Domain
import DesignSystem
import Features
import Services
import Utilities

/// Production home screen showing active protocols and primary actions.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let dependencies: DependencyContainer

    @State private var showingRunFlow = false
    @State private var showingWorkshop = false
    @State private var showingQuickTriage = false
    @State private var selectedProtocolForRun: CBTProtocol?
    @AppStorage("workshopCooldownHours") private var workshopCooldownHours = 0
    @AppStorage("lastWorkshopCompletion") private var lastWorkshopCompletionTimestamp: Double = 0

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Primary Action
                Section {
                    Button {
                        showingRunFlow = true
                    } label: {
                        Label("Start a Run", systemImage: "play.circle.fill")
                            .font(.headline)
                            .foregroundStyle(CBTColors.accent)
                    }
                    .accessibilityHint("Opens the run flow to work through a protocol")
                }

                // MARK: - Active Protocols
                if !viewModel.protocols.isEmpty {
                    Section("Your Protocols") {
                        ForEach(viewModel.protocols) { proto in
                            NavigationLink {
                                ProtocolDetailView(
                                    cbtProtocol: proto,
                                    dependencies: dependencies,
                                    onStartRun: {
                                        selectedProtocolForRun = proto
                                        showingRunFlow = true
                                    }
                                )
                            } label: {
                                protocolRow(proto)
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await viewModel.archiveProtocol(viewModel.protocols[index])
                                }
                            }
                        }
                    }
                }

                // MARK: - Build Actions
                Section {
                    Button {
                        showingWorkshop = true
                    } label: {
                        Label("Build New Protocol", systemImage: "hammer.fill")
                    }
                    .disabled(isWorkshopOnCooldown)
                    .accessibilityHint("Opens the guided workshop to create a new protocol")

                    if isWorkshopOnCooldown {
                        Text("Workshop available in \(cooldownRemainingText). Take time to reflect on your last session.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        showingQuickTriage = true
                    } label: {
                        Label("I'm Not Sure", systemImage: "questionmark.circle")
                    }
                    .accessibilityHint("Opens a quick assessment to find the right protocol for you")
                } header: {
                    Text("Actions")
                }

                // MARK: - Safety Banner
                Section {
                    let safetyInfo = SafetyInfo()
                    SafetyBanner(
                        message: safetyInfo.message,
                        resources: safetyInfo.resources.map { (name: $0.name, detail: $0.detail) }
                    )
                }
            }
            .navigationTitle("CBT")
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        DebugMenuView()
                    } label: {
                        Image(systemName: "ant")
                            .accessibilityLabel("Debug Menu")
                    }
                }
                #endif
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel: SettingsViewModel(
                            protocolRepository: dependencies.protocolRepository,
                            runRepository: dependencies.runRepository
                        ))
                    } label: {
                        Image(systemName: "gear")
                            .accessibilityLabel("Settings")
                    }
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
        }
        .fullScreenCover(isPresented: $showingRunFlow) {
            RunFlowCoordinator(
                protocolRepository: dependencies.protocolRepository,
                runRepository: dependencies.runRepository,
                safetySystem: dependencies.safetySystem,
                voiceInputService: dependencies.voiceInputService,
                onBuildNew: {
                    showingRunFlow = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingWorkshop = true
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showingWorkshop) {
            WorkshopFlowCoordinator(
                agentService: dependencies.agentService,
                protocolRepository: dependencies.protocolRepository,
                safetySystem: dependencies.safetySystem,
                voiceInputService: dependencies.voiceInputService
            )
        }
        .sheet(isPresented: $showingQuickTriage) {
            quickTriageSheet
        }
        .onChange(of: showingRunFlow) { _, isShowing in
            if !isShowing { Task { await viewModel.loadData() } }
        }
        .onChange(of: showingWorkshop) { _, isShowing in
            if !isShowing {
                lastWorkshopCompletionTimestamp = Date().timeIntervalSince1970
                Task { await viewModel.loadData() }
            }
        }
    }

    // MARK: - Workshop Cooldown

    private var isWorkshopOnCooldown: Bool {
        guard workshopCooldownHours > 0, lastWorkshopCompletionTimestamp > 0 else { return false }
        let lastCompletion = Date(timeIntervalSince1970: lastWorkshopCompletionTimestamp)
        let cooldownEnd = lastCompletion.addingTimeInterval(TimeInterval(workshopCooldownHours) * 3600)
        return Date() < cooldownEnd
    }

    private var cooldownRemainingText: String {
        guard lastWorkshopCompletionTimestamp > 0 else { return "" }
        let lastCompletion = Date(timeIntervalSince1970: lastWorkshopCompletionTimestamp)
        let cooldownEnd = lastCompletion.addingTimeInterval(TimeInterval(workshopCooldownHours) * 3600)
        let remaining = cooldownEnd.timeIntervalSince(Date())
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Subviews

    @ViewBuilder
    private func protocolRow(_ proto: CBTProtocol) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(proto.name)
                .font(.headline)
            Text(proto.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                let count = viewModel.runCount(for: proto.id)
                if count > 0 {
                    Label("\(count) runs", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                if let lastDate = viewModel.lastRunDate(for: proto.id) {
                    Label(lastDate.formatted(.relative(presentation: .named)), systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var quickTriageSheet: some View {
        NavigationStack {
            QuickTriageView(viewModel: QuickTriageViewModel(
                protocols: viewModel.protocols,
                onSelectProtocol: { proto in
                    showingQuickTriage = false
                    selectedProtocolForRun = proto
                    showingRunFlow = true
                },
                onBuildNew: {
                    showingQuickTriage = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingWorkshop = true
                    }
                }
            ))
        }
    }
}

#Preview {
    let deps = DependencyContainer.makePreview()
    HomeView(
        viewModel: HomeViewModel(
            protocolRepository: deps.protocolRepository,
            runRepository: deps.runRepository
        ),
        dependencies: deps
    )
}
