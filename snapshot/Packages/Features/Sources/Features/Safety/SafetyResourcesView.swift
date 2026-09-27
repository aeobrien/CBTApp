import SwiftUI
import Domain
import DesignSystem

/// Full-screen modal displaying safety resources when a safety alert is triggered.
public struct SafetyResourcesView: View {
    let alert: SafetyAlert
    let onContinue: () -> Void

    public init(alert: SafetyAlert, onContinue: @escaping () -> Void) {
        self.alert = alert
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundStyle(CBTColors.info)
                .accessibilityHidden(true)

            Text("Support is available")
                .font(.title2)
                .fontWeight(.semibold)

            Text(alert.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                ForEach(alert.resources) { resource in
                    SafetyResourceCard(resource: resource)
                }
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                if alert.canContinue {
                    Button {
                        onContinue()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(CBTColors.accent)
                }

                Button {
                    onContinue()
                } label: {
                    Text("I'm safe, close this")
                        .foregroundStyle(.secondary)
                }
                .disabled(!alert.canContinue)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(CBTColors.safetyBackground)
        .interactiveDismissDisabled(!alert.canContinue)
    }
}

/// A card displaying a single safety resource with tappable phone/URL links.
private struct SafetyResourceCard: View {
    let resource: SafetyResource

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resource.name)
                .font(.headline)

            Text(resource.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                if let phone = resource.phoneNumber, let phoneURL = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                    Link(destination: phoneURL) {
                        Label(phone, systemImage: "phone.fill")
                            .font(.subheadline)
                    }
                }
                if let urlString = resource.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Label("Website", systemImage: "globe")
                            .font(.subheadline)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// View modifier that presents a full-screen safety cover when an alert is present.
public struct SafetyCoverModifier: ViewModifier {
    @Binding var alert: SafetyAlert?

    public func body(content: Content) -> some View {
        #if os(iOS)
        content.fullScreenCover(item: $alert) { activeAlert in
            SafetyResourcesView(alert: activeAlert) {
                alert = nil
            }
        }
        #else
        content.sheet(item: $alert) { activeAlert in
            SafetyResourcesView(alert: activeAlert) {
                alert = nil
            }
        }
        #endif
    }
}

extension View {
    /// Present a full-screen safety resource view when an alert is present.
    public func safetyCover(alert: Binding<SafetyAlert?>) -> some View {
        modifier(SafetyCoverModifier(alert: alert))
    }
}

#Preview("Acute Risk") {
    SafetyResourcesView(
        alert: SafetyAlert(
            kind: .acuteRisk,
            message: "It sounds like you may be in crisis. Please reach out to one of the support services below.",
            canContinue: false
        ),
        onContinue: {}
    )
}

#Preview("Elevated Risk") {
    SafetyResourcesView(
        alert: SafetyAlert(
            kind: .acuteRisk,
            message: "It sounds like you're going through a really difficult time. Support is available if you need it.",
            canContinue: true
        ),
        onContinue: {}
    )
}
