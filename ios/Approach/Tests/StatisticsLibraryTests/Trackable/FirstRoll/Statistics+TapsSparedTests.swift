import Dependencies
import ModelsLibrary
@testable import StatisticsLibrary
import XCTest

final class TapsSparedTests: XCTestCase {
	func testAdjust_ByFramesWithTapsSpared_Adjusts() {
		let statistic = create(
			statistic: Statistics.TapsSpared.self,
			adjustedByFrames: [
				Frame.TrackableEntry(
					index: 0,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.leftThreePin, .headPin, .rightThreePin, .rightTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [.leftTwoPin])),
					]
				),
				Frame.TrackableEntry(
					index: 1,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.leftThreePin, .headPin, .rightThreePin, .rightTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [])),
						.init(index: 2, roll: .init(pinsDowned: [.leftTwoPin])),
					]
				),
				Frame.TrackableEntry(
					index: 2,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.rightThreePin, .headPin, .leftThreePin, .leftTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [.rightTwoPin])),
					]
				),
				Frame.TrackableEntry(
					index: 3,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.rightThreePin, .headPin, .leftThreePin, .leftTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [])),
						.init(index: 2, roll: .init(pinsDowned: [.rightTwoPin])),
					]
				),
			],
			withFrameConfiguration: .default
		)

		AssertPercentage(statistic, hasNumerator: 2, withDenominator: 4, formattedAs: "50% (2)")
	}

	func testAdjust_ByFramesWithoutTapsSpared_DoesNotAdjust() {
		let statistic = create(
			statistic: Statistics.TapsSpared.self,
			adjustedByFrames: [
				Frame.TrackableEntry(
					index: 0,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.leftThreePin, .headPin, .rightThreePin, .rightTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [])),
					]
				),
				Frame.TrackableEntry(
					index: 1,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.leftThreePin, .headPin, .rightThreePin, .rightTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [])),
						.init(index: 2, roll: .init(pinsDowned: [.leftTwoPin])),
					]
				),
				Frame.TrackableEntry(
					index: 2,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.rightThreePin, .headPin, .leftThreePin, .leftTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [])),
					]
				),
				Frame.TrackableEntry(
					index: 3,
					rolls: [
						.init(index: 0, roll: .init(pinsDowned: [.rightThreePin, .headPin, .leftThreePin, .leftTwoPin])),
						.init(index: 1, roll: .init(pinsDowned: [])),
						.init(index: 2, roll: .init(pinsDowned: [.rightTwoPin])),
					]
				),
			],
			withFrameConfiguration: .default
		)

		AssertPercentage(statistic, hasNumerator: 0, withDenominator: 4, formattedAs: "0%", overridingIsEmptyExpectation: true)
	}

	func testAdjustBySeries_DoesNothing() {
		let statistic = create(statistic: Statistics.TapsSpared.self, adjustedBySeries: Series.TrackableEntry.mocks)
		AssertPercentage(statistic, hasNumerator: 0, withDenominator: 0, formattedAs: "0%")
	}

	func testAdjustByGame_DoesNothing() {
		let statistic = create(statistic: Statistics.TapsSpared.self, adjustedByGames: Game.TrackableEntry.mocks)
		AssertPercentage(statistic, hasNumerator: 0, withDenominator: 0, formattedAs: "0%")
	}
}
