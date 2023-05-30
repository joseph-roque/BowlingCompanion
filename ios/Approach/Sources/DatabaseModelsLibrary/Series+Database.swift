import Foundation
import GRDB
import ModelsLibrary

extension Series {
	public struct Database: Sendable, Identifiable, Codable, Equatable, TableRecord {
		public static let databaseTableName = "series"

		public let leagueId: League.ID
		public let id: Series.ID
		public var date: Date
		public var numberOfGames: Int
		public var preBowl: PreBowl
		public var excludeFromStatistics: ExcludeFromStatistics
		public var alleyId: Alley.ID?

		public init(
			leagueId: League.ID,
			id: Series.ID,
			date: Date,
			numberOfGames: Int,
			preBowl: PreBowl,
			excludeFromStatistics: ExcludeFromStatistics,
			alleyId: Alley.ID?
		) {
			self.leagueId = leagueId
			self.id = id
			self.date = date
			self.numberOfGames = numberOfGames
			self.preBowl = preBowl
			self.excludeFromStatistics = excludeFromStatistics
			self.alleyId = alleyId
		}
	}
}

extension Series.PreBowl: DatabaseValueConvertible {}
extension Series.ExcludeFromStatistics: DatabaseValueConvertible {}

extension Series.Database: FetchableRecord, PersistableRecord {
	public static let league = belongsTo(League.Database.self)
	public static let alley = belongsTo(Alley.Database.self)
	public static let games = hasMany(Game.Database.self)

	public static let seriesLanes = hasMany(SeriesLane.Database.self)
	public static let lanes = hasMany(Lane.Database.self, through: seriesLanes, using: SeriesLane.Database.lane)

	public static let trackableGames = hasMany(Game.Database.self)
		.filter(Game.Database.Columns.excludeFromStatistics == Game.ExcludeFromStatistics.include)
	public static let trackableFrames = hasMany(Frame.Database.self, through: trackableGames, using: Game.Database.frames)
}

extension Series.Database {
	public enum Columns {
		public static let leagueId = Column(CodingKeys.leagueId)
		public static let id = Column(CodingKeys.id)
		public static let date = Column(CodingKeys.date)
		public static let numberOfGames = Column(CodingKeys.numberOfGames)
		public static let preBowl = Column(CodingKeys.preBowl)
		public static let excludeFromStatistics = Column(CodingKeys.excludeFromStatistics)
		public static let alleyId = Column(CodingKeys.alleyId)
	}
}

extension Series.Summary: TableRecord, FetchableRecord {
	public static let databaseTableName = Series.Database.databaseTableName
}