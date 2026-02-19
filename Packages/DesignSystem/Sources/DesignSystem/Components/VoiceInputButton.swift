import SwiftUI

/// Microphone button for voice input.
///
/// UI-only in Phase 2 — actual transcription wired in Phase 11.
/// Shows recording state with pulsing animation.
public struct VoiceInputButton: View {
    let isRecording: Bool
    let action: () -> Void

    public init(isRecording: Bool, action: @escaping () -> Void) {
        self.isRecording = isRecording
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording {
                    Circle()
                        .fill(CBTColors.negative.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .phaseAnimator([false, true]) { content, phase in
                            content
                                .scaleEffect(phase ? 1.2 : 1.0)
                                .opacity(phase ? 0.5 : 1.0)
                        } animation: { _ in
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        }
                }

                Circle()
                    .fill(isRecording ? CBTColors.negative : CBTColors.accent)
                    .frame(width: CBTSpacing.minTouchTarget, height: CBTSpacing.minTouchTarget)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRecording ? "Stop recording" : "Start voice input")
    }
}

#Preview {
    HStack(spacing: 32) {
        VoiceInputButton(isRecording: false) {}
        VoiceInputButton(isRecording: true) {}
    }
}
