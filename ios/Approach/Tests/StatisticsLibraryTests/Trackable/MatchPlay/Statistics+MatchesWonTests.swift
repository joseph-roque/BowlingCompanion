import Dependencies
import ModelsLibrary
@testable import StatisticsLibrary
import XCTest

final class MatchesWonTests: XCTestCase {
	func testAdjustByGame() {
		let statistic = create(statistic: Statistics.MatchesWon.self, adjustedByGames: Game.TrackableEntry.mocks)
		AssertPercentage(statistic, hasNumerator: 3, withDenominator: 9, formattedAs: "33.3% (3)")
	}

	func testAdjustBySeries_DoesNothing() {
		let statistic = create(statistic: Statistics.MatchesWon.self, adjustedBySeries: Series.TrackableEntry.mocks)
		AssertPercentage(statistic, hasNumerator: 0, withDenominator: 0, formattedAs: "0%")
	}

	func testAdjustByFrame_DoesNothing() {
		let statistic = create(statistic: Statistics.MatchesWon.self, adjustedByFrames: Frame.TrackableEntry.mocks)
		AssertPercentage(statistic, hasNumerator: 0, withDenominator: 0, formattedAs: "0%")
	}
}
