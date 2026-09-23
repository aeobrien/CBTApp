import SwiftUI
import Domain
import DesignSystem
import UniformTypeIdentifiers

/// App settings: API key, data export/import, protocol management, about.
public struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingDeleteConfirmation: CBTProtocol?

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            // MARK: - API Key
            Section("OpenAI API Key") {
                SecureField("API Key", text: $viewModel.apiKey)
                    .textContentType(.password)
                    #if os(iOS)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    #endif

                Button("Save Key") {
                    viewModel.saveAPIKey()
                }
                .disabled(viewModel.apiKey.isEmpty)

                if viewModel.apiKeySaved {
                    Label("Key saved", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(CBTColors.positive)
                        .font(CBTTypography.caption)
                }
            }

            // MARK: - Security
            Section("Security") {
                Toggle("App Lock (Face ID / Passcode)", isOn: $viewModel.appLockEnabled)

                if let message = viewModel.appLockUnavailableMessage {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(CBTColors.negative)
                        .font(CBTTypography.caption)
                }
            }

            // MARK: - Appearance
            Section("Appearance") {
                Picker("Theme", selection: $viewModel.appearanceOverride) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
            }

            // MARK: - Workshop
            Section("Workshop") {
                Stepper(
                    "Cooldown: \(viewModel.workshopCooldownHours == 0 ? "Off" : "\(viewModel.workshopCooldownHours)h")",
                    value: $viewModel.workshopCooldownHours,
                    in: 0...72,
                    step: 4
                )
                if viewModel.workshopCooldownHours > 0 {
                    Text("Wait \(viewModel.workshopCooldownHours) hours between workshops to allow time for reflection.")
                        .font(CBTTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Data Management
            Section("Data") {
                Button {
                    Task { await viewModel.exportProtocols() }
                    showingExporter = true
                } label: {
                    Label("Export Protocols", systemImage: "square.and.arrow.up")
                }

                Button {
                    showingImporter = true
                } label: {
                    Label("Import Protocols", systemImage: "square.and.arrow.down")
                }

                Button(role: .destructive) {
                    viewModel.showingResetConfirmation = true
                } label: {
                    Label("Reset All Run Data", systemImage: "trash")
                }

                if viewModel.importSuccess {
                    Label("Import successful", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(CBTColors.positive)
                        .font(CBTTypography.caption)
                }

                if viewModel.resetSuccess {
                    Label("Run data reset", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(CBTColors.positive)
                        .font(CBTTypography.caption)
                }

                if let error = viewModel.importError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(CBTColors.negative)
                        .font(CBTTypography.caption)
                }
            }

            // MARK: - Data Disclosure
            Section("What Gets Sent to the AI Agent") {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Situation text", systemImage: "text.quote")
                    Label("Hot thought", systemImage: "brain.head.profile")
                    Label("Emotion labels (no intensity)", systemImage: "heart")
                    Label("Intervention type", systemImage: "wrench.and.screwdriver")
                }
                .font(CBTTypography.caption)

                Text("Your data is sent only to OpenAI's API and is not stored by them under their API data policy.")
                    .font(CBTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Protocol Management
            Section("Protocols") {
                if viewModel.protocols.isEmpty {
                    Text("No protocols")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.protocols) { proto in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(proto.name)
                                    .font(CBTTypography.body)
                                Text(proto.status.displayName)
                                    .font(CBTTypography.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if proto.status != .archived {
                                Button {
                                    Task { await viewModel.archiveProtocol(proto) }
                                } label: {
                                    Image(systemName: "archivebox")
                                }
                                .buttonStyle(.borderless)
                            }

                            Button(role: .destructive) {
                                showingDeleteConfirmation = proto
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            // MARK: - About
            Section("About") {
                Button("Reset Onboarding") {
                    viewModel.resetOnboarding()
                }
            }
        }
        .navigationTitle("Settings")
        .task { await viewModel.loadSettings() }
        .fileExporter(
            isPresented: $showingExporter,
            document: JSONDocument(data: viewModel.exportData ?? Data()),
            contentType: .json,
            defaultFilename: "cbt-protocols-export"
        ) { _ in }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    Task { await viewModel.importProtocols(from: data) }
                }
            case .failure:
                break
            }
        }
        .alert("Reset All Run Data?", isPresented: $viewModel.showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                Task { await viewModel.resetAllRunData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all run history and metrics. Your protocols will not be affected.")
        }
        .alert(
            "Delete Protocol?",
            isPresented: Binding(
                get: { showingDeleteConfirmation != nil },
                set: { if !$0 { showingDeleteConfirmation = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let proto = showingDeleteConfirmation {
                    Task { await viewModel.deleteProtocol(proto) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the protocol and all its runs.")
        }
    }
}

/// Simple document wrapper for JSON file export.
struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: .preview())
    }
}
