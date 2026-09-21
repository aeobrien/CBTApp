import Testing
import Foundation
@testable import DesignSystem
@testable import Domain

@Suite("DesignSystem Module")
struct DesignSystemModuleTests {
    @Test("Module initialises with correct version")
    func moduleVersion() {
        #expect(DesignSystemModule.version == "0.1.0")
    }
}

@Suite("Design Tokens")
struct DesignTokenTests {

    @Test("CBTSpacing values follow 4pt grid")
    func spacingGrid() {
        #expect(CBTSpacing.xxs == 4)
        #expect(CBTSpacing.xs == 8)
        #expect(CBTSpacing.sm == 12)
        #expect(CBTSpacing.md == 16)
        #expect(CBTSpacing.lg == 24)
        #expect(CBTSpacing.xl == 32)
        #expect(CBTSpacing.xxl == 48)
    }

    @Test("CBTSpacing component values are reasonable")
    func spacingComponents() {
        #expect(CBTSpacing.cardRadius > 0)
        #expect(CBTSpacing.chipRadius > 0)
        #expect(CBTSpacing.minTouchTarget >= 44) // Apple HIG minimum
        #expect(CBTSpacing.sliderThumb > 0)
    }
}

@Suite("TimerModel")
struct TimerModelTests {

    @Test("Initial state is not running with zero elapsed")
    func initialState() {
        let model = TimerModel(targetDuration: 60)
        #expect(model.elapsed == 0)
        #expect(model.isRunning == false)
        #expect(model.isComplete == false)
        #expect(model.progress == 0)
    }

    @Test("Display time formats correctly for countdown")
    func countdownDisplay() {
        let model = TimerModel(targetDuration: 180)
        #expect(model.displayTime == "3:00")

        model.elapsed = 60
        #expect(model.displayTime == "2:00")

        model.elapsed = 179
        #expect(model.displayTime == "0:01")

        model.elapsed = 180
        #expect(model.displayTime == "0:00")
    }

    @Test("Display time formats correctly for countup")
    func countupDisplay() {
        let model = TimerModel()
        #expect(model.displayTime == "0:00")

        model.elapsed = 65
        #expect(model.displayTime == "1:05")

        model.elapsed = 3661
        #expect(model.displayTime == "61:01")
    }

    @Test("Progress calculation")
    func progress() {
        let model = TimerModel(targetDuration: 100)
        #expect(model.progress == 0)

        model.elapsed = 50
        #expect(model.progress == 0.5)

        model.elapsed = 100
        #expect(model.progress == 1.0)

        model.elapsed = 150 // over target
        #expect(model.progress == 1.0)
    }

    @Test("Progress is zero when no target duration")
    func noTargetProgress() {
        let model = TimerModel()
        model.elapsed = 100
        #expect(model.progress == 0)
    }

    @Test("isComplete reflects target reached")
    func completion() {
        let model = TimerModel(targetDuration: 60)
        #expect(model.isComplete == false)

        model.elapsed = 59
        #expect(model.isComplete == false)

        model.elapsed = 60
        #expect(model.isComplete == true)
    }

    @Test("isComplete is false when no target")
    func noTargetCompletion() {
        let model = TimerModel()
        model.elapsed = 9999
        #expect(model.isComplete == false)
    }

    @Test("Reset clears elapsed and stops timer")
    func reset() {
        let model = TimerModel(targetDuration: 60)
        model.elapsed = 30
        model.isRunning = true
        model.reset()

        #expect(model.elapsed == 0)
        #expect(model.isRunning == false)
    }

    @Test("Start sets running, pause clears it")
    func startPause() {
        let model = TimerModel()
        #expect(model.isRunning == false)

        model.start()
        #expect(model.isRunning == true)

        model.pause()
        #expect(model.isRunning == false)
    }

    @Test("Double start does not crash")
    func doubleStart() {
        let model = TimerModel()
        model.start()
        model.start() // should be no-op
        #expect(model.isRunning == true)
        model.pause()
    }
}

@Suite("OutcomeTag Integration")
struct OutcomeTagTests {

    @Test("All OutcomeTags have display names for chips")
    func allTagsHaveDisplayNames() {
        for tag in OutcomeTag.allCases {
            #expect(!tag.displayName.isEmpty)
        }
    }

    @Test("OutcomeTag is Hashable for Set selection")
    func hashableForSelection() {
        var selection = Set<OutcomeTag>()
        selection.insert(.predictionDidntHappen)
        selection.insert(.uncomfortableButTolerable)
        #expect(selection.count == 2)

        selection.remove(.predictionDidntHappen)
        #expect(selection.count == 1)
    }
}
