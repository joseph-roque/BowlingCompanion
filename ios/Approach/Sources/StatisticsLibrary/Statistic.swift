import Foundation
import ModelsLibrary
import StringsLibrary

public enum Statistics {}

public protocol Statistic {
	static var title: String { get }
	static var category: StatisticCategory { get }
	static var supportsAggregation: Bool { get }

	var formattedValue: String { get }
	var isEmpty: Bool { get }

	init()

	static func supports(trackableSource: TrackableFilter.Source) -> Bool

	mutating func adjust(byFrame: Frame.TrackableEntry, configuration: TrackablePerFrameConfiguration)
	mutating func adjust(byGame: Game.TrackableEntry, configuration: TrackablePerGameConfiguration)
	mutating func adjust(bySeries: Series.TrackableEntry, configuration: TrackablePerSeriesConfiguration)
	mutating func aggregate(with: Statistic)
}

// MARK: - Category

public enum StatisticCategory: CaseIterable, CustomStringConvertible {
	case overall
	case onFirstRoll
	case fouls
	case pinsLeftOnDeck
	case matchPlayResults
	case average
	case series

	public var description: String {
		switch self {
		case .overall: return Strings.Statistics.Categories.Overall.title
		case .onFirstRoll: return Strings.Statistics.Categories.OnFirstRoll.title
		case .fouls: return Strings.Statistics.Categories.Fouls.title
		case .pinsLeftOnDeck: return Strings.Statistics.Categories.PinsLeftOnDeck.title
		case .matchPlayResults: return Strings.Statistics.Categories.MatchPlay.title
		case .average: return Strings.Statistics.Categories.Average.title
		case .series: return Strings.Statistics.Categories.Series.title
		}
	}
}

// MARK: - Trackable Per Frame

public struct TrackablePerFrameConfiguration {
	public let countHeadPin2AsHeadPin: Bool

	public init(countHeadPin2AsHeadPin: Bool) {
		self.countHeadPin2AsHeadPin = countHeadPin2AsHeadPin
	}
}

public protocol TrackablePerFrame: Statistic {}
extension TrackablePerFrame {
	public mutating func adjust(byGame: Game.TrackableEntry, configuration: TrackablePerGameConfiguration) {}
	public mutating func adjust(bySeries: Series.TrackableEntry, configuration: TrackablePerSeriesConfiguration) {}
}

// MARK: Trackable Per First Roll

public protocol TrackablePerFirstRoll: TrackablePerFrame {
	mutating func adjust(byFirstRoll: Frame.OrderedRoll, configuration: TrackablePerFrameConfiguration)
}

extension TrackablePerFirstRoll {
	public mutating func adjust(byFrame: Frame.TrackableEntry, configuration: TrackablePerFrameConfiguration) {
		for roll in byFrame.firstRolls {
			adjust(byFirstRoll: roll, configuration: configuration)
		}
	}
}

// MARK: Trackable Per Second Roll

public protocol TrackablePerSecondRoll: TrackablePerFrame {
	mutating func adjust(
		bySecondRoll: Frame.OrderedRoll,
		afterFirstRoll: Frame.OrderedRoll,
		configuration: TrackablePerFrameConfiguration
	)
}

extension TrackablePerSecondRoll {
	public mutating func adjust(byFrame: Frame.TrackableEntry, configuration: TrackablePerFrameConfiguration) {
		for (firstRoll, secondRoll) in zip(byFrame.firstRolls, byFrame.secondRolls) {
			adjust(bySecondRoll: secondRoll, afterFirstRoll: firstRoll, configuration: configuration)
		}
	}
}

// MARK: - Trackable Per Game

public struct TrackablePerGameConfiguration {
	public init() {}
}

public protocol TrackablePerGame: Statistic {}
extension TrackablePerGame {
	public mutating func adjust(byFrame: Frame.TrackableEntry, configuration: TrackablePerFrameConfiguration) {}
	public mutating func adjust(bySeries: Series.TrackableEntry, configuration: TrackablePerSeriesConfiguration) {}
}

// MARK: - Trackable Per Series

public struct TrackablePerSeriesConfiguration {
	public init() {}
}

public protocol TrackablePerSeries: Statistic {}
extension TrackablePerSeries {
	public mutating func adjust(byFrame: Frame.TrackableEntry, configuration: TrackablePerFrameConfiguration) {}
	public mutating func adjust(byGame: Game.TrackableEntry, configuration: TrackablePerGameConfiguration) {}
}
