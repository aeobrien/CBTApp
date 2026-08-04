import SwiftUI
import Combine

/// A prominent but calm countdown/countup timer.
///
/// Used during timed interventions (e.g. defusion exercises,
/// delay experiments). Shows elapsed or remaining time with
/// start/pause/reset controls.
@Observable
public final class TimerModel {
    public var elapsed: TimeInterval = 0
    public var targetDuration: TimeInterval?
    public var isRunning = false

    private var timer: (any Cancellable)?

    public init(targetDuration: TimeInterval? = nil) {
        self.targetDuration = targetDuration
    }

    public var displayTime: String {
        let total: TimeInterval
        if let target = targetDuration {
            total = max(target - elapsed, 0)
        } else {
            total = elapsed
        }
        let minutes = Int(total) / 60
        let seconds = Int(total) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var progress: Double {
        guard let target = targetDuration, target > 0 else { return 0 }
        return min(elapsed / target, 1.0)
    }

    public var isComplete: Bool {
        guard let target = targetDuration else { return false }
        return elapsed >= target
    }

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isRunning else { return }
                self.elapsed += 1
                if self.isComplete {
                    self.pause()
                }
            }
    }

    public func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    public func reset() {
        pause()
        elapsed = 0
    }
}

/// Timer view with large time display and controls.
public struct CBTTimerView: View {
    @Bindable var model: TimerModel

    public init(model: TimerModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: CBTSpacing.md) {
            Text(model.displayTime)
                .font(CBTTypography.timer)
                .foregroundStyle(model.isComplete ? CBTColors.positive : .primary)
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.1), value: model.elapsed)

            if model.targetDuration != nil {
                ProgressView(value: model.progress)
                    .tint(model.isComplete ? CBTColors.positive : CBTColors.accent)
                    .animation(.linear(duration: 0.3), value: model.progress)
            }

            HStack(spacing: CBTSpacing.lg) {
                Button {
                    model.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .disabled(model.elapsed == 0)

                Button {
                    if model.isRunning {
                        model.pause()
                    } else {
                        model.start()
                    }
                } label: {
                    Image(systemName: model.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(CBTColors.accent)
                }
                .disabled(model.isComplete)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timer")
        .accessibilityValue(model.displayTime)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    VStack(spacing: 32) {
        CBTTimerView(model: TimerModel(targetDuration: 180))
        CBTTimerView(model: TimerModel())
    }
    .padding()
}
