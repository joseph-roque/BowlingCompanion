import Foundation
import ModelsLibrary

extension Series {
	public struct Edit: Identifiable, Equatable, Codable {
		public let leagueId: League.ID
		public let id: Series.ID
		public let numberOfGames: Int

		public var date: Date
		public var preBowl: PreBowl
		public var excludeFromStatistics: ExcludeFromStatistics
		public var location: Alley.Summary?
	}
}

extension Series {
	public struct EditWithLanes: Equatable, Codable {
		public var existing: Edit
		public var lanes: [Lane.Summary]
	}
}
