import Foundation
import GRDB
import ModelsLibrary

extension Lane {
	public struct Database: Sendable, Identifiable, Codable, Equatable, TableRecord {
		public static let databaseTableName = "lane"

		public let alleyId: Alley.ID
		public let id: Lane.ID
		public var label: String
		public var position: Lane.Position

		public init(
			alleyId: Alley.ID,
			id: Lane.ID,
			label: String,
			position: Lane.Position
		) {
			self.alleyId = alleyId
			self.id = id
			self.label = label
			self.position = position
		}
	}
}

extension Lane.Position: DatabaseValueConvertible {}

extension Lane.Database: FetchableRecord, PersistableRecord {}

extension DerivableRequest<Lane.Database> {
	public func orderByLabel() -> Self {
		let label = Lane.Database.Columns.label
		return order(label.collating(.localizedCaseInsensitiveCompare))
	}

	public func filter(byAlley: Alley.ID?) -> Self {
		guard let byAlley else { return self }
		let alley = Lane.Database.Columns.alleyId
		return filter(alley == byAlley)
	}
}

extension Lane.Database {
	public enum Columns {
		public static let alleyId = Column(CodingKeys.alleyId)
		public static let id = Column(CodingKeys.id)
		public static let label = Column(CodingKeys.label)
		public static let position = Column(CodingKeys.position)
	}
}

extension Lane.Summary: TableRecord, FetchableRecord {
	public static let databaseTableName = Lane.Database.databaseTableName
}