import Testing
import Foundation
@testable import Domain

@Suite("Enum Codable Round-Trips")
struct EnumCodableTests {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    @Test("EmotionType encodes and decodes all cases")
    func emotionTypeRoundTrip() throws {
        for emotion in EmotionType.allCases {
            let data = try encoder.encode(emotion)
            let decoded = try decoder.decode(EmotionType.self, from: data)
            #expect(decoded == emotion)
        }
    }

    @Test("UrgeType encodes and decodes all cases")
    func urgeTypeRoundTrip() throws {
        for urge in UrgeType.allCases {
            let data = try encoder.encode(urge)
            let decoded = try decoder.decode(UrgeType.self, from: data)
            #expect(decoded == urge)
        }
    }

    @Test("BodySignal encodes and decodes all cases")
    func bodySignalRoundTrip() throws {
        for signal in BodySignal.allCases {
            let data = try encoder.encode(signal)
            let decoded = try decoder.decode(BodySignal.self, from: data)
            #expect(decoded == signal)
        }
    }

    @Test("OutcomeTag encodes and decodes all cases")
    func outcomeTagRoundTrip() throws {
        for tag in OutcomeTag.allCases {
            let data = try encoder.encode(tag)
            let decoded = try decoder.decode(OutcomeTag.self, from: data)
            #expect(decoded == tag)
        }
    }

    @Test("ProtocolStatus encodes and decodes all cases")
    func protocolStatusRoundTrip() throws {
        for status in ProtocolStatus.allCases {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(ProtocolStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test("InterventionType encodes and decodes all cases")
    func interventionTypeRoundTrip() throws {
        for type in InterventionType.allCases {
            let data = try encoder.encode(type)
            let decoded = try decoder.decode(InterventionType.self, from: data)
            #expect(decoded == type)
        }
    }

    @Test("MeasureFrequency encodes and decodes all cases")
    func measureFrequencyRoundTrip() throws {
        for freq in MeasureFrequency.allCases {
            let data = try encoder.encode(freq)
            let decoded = try decoder.decode(MeasureFrequency.self, from: data)
            #expect(decoded == freq)
        }
    }

    @Test("RunCompletionStatus encodes and decodes all cases")
    func runCompletionStatusRoundTrip() throws {
        for status in RunCompletionStatus.allCases {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(RunCompletionStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test("MaintainingBehaviourType encodes and decodes all cases")
    func maintainingBehaviourTypeRoundTrip() throws {
        for type in MaintainingBehaviourType.allCases {
            let data = try encoder.encode(type)
            let decoded = try decoder.decode(MaintainingBehaviourType.self, from: data)
            #expect(decoded == type)
        }
    }

    @Test("TargetLoopType encodes and decodes all cases")
    func targetLoopTypeRoundTrip() throws {
        for type in TargetLoopType.allCases {
            let data = try encoder.encode(type)
            let decoded = try decoder.decode(TargetLoopType.self, from: data)
            #expect(decoded == type)
        }
    }
}

@Suite("Enum Display Names")
struct EnumDisplayNameTests {
    @Test("All EmotionType cases have non-empty display names")
    func emotionDisplayNames() {
        for emotion in EmotionType.allCases {
            #expect(!emotion.displayName.isEmpty)
        }
    }

    @Test("All UrgeType cases have non-empty display names")
    func urgeDisplayNames() {
        for urge in UrgeType.allCases {
            #expect(!urge.displayName.isEmpty)
        }
    }

    @Test("All BodySignal cases have non-empty display names")
    func bodySignalDisplayNames() {
        for signal in BodySignal.allCases {
            #expect(!signal.displayName.isEmpty)
        }
    }

    @Test("All OutcomeTag cases have non-empty display names")
    func outcomeTagDisplayNames() {
        for tag in OutcomeTag.allCases {
            #expect(!tag.displayName.isEmpty)
        }
    }

    @Test("All InterventionType cases have non-empty display names")
    func interventionTypeDisplayNames() {
        for type in InterventionType.allCases {
            #expect(!type.displayName.isEmpty)
        }
    }

    @Test("All MaintainingBehaviourType cases have non-empty display names")
    func maintainingBehaviourDisplayNames() {
        for type in MaintainingBehaviourType.allCases {
            #expect(!type.displayName.isEmpty)
        }
    }
}

@Suite("Enum Properties")
struct EnumPropertyTests {
    @Test("MeasureFrequency interval days are positive")
    func measureFrequencyIntervals() {
        for freq in MeasureFrequency.allCases {
            #expect(freq.intervalDays > 0)
        }
    }

    @Test("MeasureFrequency weekly is 7 days")
    func weeklyInterval() {
        #expect(MeasureFrequency.weekly.intervalDays == 7)
    }

    @Test("MeasureFrequency fortnightly is 14 days")
    func fortnightlyInterval() {
        #expect(MeasureFrequency.fortnightly.intervalDays == 14)
    }

    @Test("RunCompletionStatus.completed isComplete is true")
    func completedIsComplete() {
        #expect(RunCompletionStatus.completed.isComplete == true)
    }

    @Test("RunCompletionStatus.abandoned isComplete is false")
    func abandonedIsNotComplete() {
        #expect(RunCompletionStatus.abandoned.isComplete == false)
    }

    @Test("Partial skip statuses are still considered complete")
    func partialSkipsAreComplete() {
        #expect(RunCompletionStatus.partialSkippedCapture.isComplete == true)
        #expect(RunCompletionStatus.partialSkippedDiscovery.isComplete == true)
        #expect(RunCompletionStatus.partialSkippedSummary.isComplete == true)
    }

    @Test("All Identifiable enums have non-empty ids")
    func identifiableIds() {
        for e in EmotionType.allCases { #expect(!e.id.isEmpty) }
        for u in UrgeType.allCases { #expect(!u.id.isEmpty) }
        for b in BodySignal.allCases { #expect(!b.id.isEmpty) }
        for o in OutcomeTag.allCases { #expect(!o.id.isEmpty) }
        for p in ProtocolStatus.allCases { #expect(!p.id.isEmpty) }
        for i in InterventionType.allCases { #expect(!i.id.isEmpty) }
        for m in MeasureFrequency.allCases { #expect(!m.id.isEmpty) }
        for r in RunCompletionStatus.allCases { #expect(!r.id.isEmpty) }
    }
}
