import XCTest
@testable import Domain

final class MeasureDefinitionTests: XCTestCase {

    func testPHQ9Has9Items() {
        XCTAssertEqual(MeasureDefinition.phq9.items.count, 9)
    }

    func testGAD7Has7Items() {
        XCTAssertEqual(MeasureDefinition.gad7.items.count, 7)
    }

    func testPHQ9MaxScoreIs27() {
        XCTAssertEqual(MeasureDefinition.phq9.maxScore, 27)
    }

    func testGAD7MaxScoreIs21() {
        XCTAssertEqual(MeasureDefinition.gad7.maxScore, 21)
    }

    func testResponseOptionsHas4Items() {
        XCTAssertEqual(MeasureDefinition.phq9.responseOptions.count, 4)
        XCTAssertEqual(MeasureDefinition.gad7.responseOptions.count, 4)
    }

    func testPHQ9ScoringBandLookup() {
        XCTAssertEqual(MeasureDefinition.phq9.band(for: 0)?.severity, .minimal)
        XCTAssertEqual(MeasureDefinition.phq9.band(for: 4)?.severity, .minimal)
        XCTAssertEqual(MeasureDefinition.phq9.band(for: 5)?.severity, .mild)
        XCTAssertEqual(MeasureDefinition.phq9.band(for: 12)?.severity, .moderate)
        XCTAssertEqual(MeasureDefinition.phq9.band(for: 17)?.severity, .moderatelySevere)
        XCTAssertEqual(MeasureDefinition.phq9.band(for: 25)?.severity, .severe)
    }

    func testGAD7ScoringBandLookup() {
        XCTAssertEqual(MeasureDefinition.gad7.band(for: 2)?.severity, .minimal)
        XCTAssertEqual(MeasureDefinition.gad7.band(for: 7)?.severity, .mild)
        XCTAssertEqual(MeasureDefinition.gad7.band(for: 12)?.severity, .moderate)
        XCTAssertEqual(MeasureDefinition.gad7.band(for: 18)?.severity, .severe)
    }

    func testFromMeasureID() {
        XCTAssertEqual(MeasureDefinition.from(measureID: "PHQ-9"), .phq9)
        XCTAssertEqual(MeasureDefinition.from(measureID: "GAD-7"), .gad7)
        XCTAssertNil(MeasureDefinition.from(measureID: "UNKNOWN"))
    }

    func testScoringBandOutOfRange() {
        XCTAssertNil(MeasureDefinition.phq9.band(for: -1))
        XCTAssertNil(MeasureDefinition.phq9.band(for: 28))
    }
}
