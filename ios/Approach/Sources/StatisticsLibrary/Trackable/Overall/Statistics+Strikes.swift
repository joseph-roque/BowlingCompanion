import ModelsLibrary
import StringsLibrary

extension Statistics {
	public struct Strikes: Statistic, TrackablePerFirstRoll, FirstRollStatistic {
		public static var title: String { Strings.Statistics.Title.strikes }
		public static var category: StatisticCategory { .overall }

		public var totalRolls = 0
		private var strikes = 0

		public var numerator: Int {
			get { strikes }
			set { strikes = newValue }
		}

		public init() {}
		init(strikes: Int, totalRolls: Int) {
			self.strikes = strikes
			self.totalRolls = totalRolls
		}

		public mutating func tracks(firstRoll: Frame.OrderedRoll, configuration: TrackablePerFrameConfiguration) -> Bool {
			firstRoll.roll.pinsDowned.arePinsCleared
		}

		public static func supports(trackableSource: TrackableFilter.Source) -> Bool {
			switch trackableSource {
			case .bowler, .league, .series, .game: return true
			}
		}
	}
}