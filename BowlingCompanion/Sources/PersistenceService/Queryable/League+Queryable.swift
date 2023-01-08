import GRDB
import PersistenceServiceInterface
import SharedModelsLibrary
import SharedModelsFetchableLibrary
import SharedModelsPersistableLibrary

extension League.FetchRequest: ManyQueryable {
	@Sendable func fetchValues(_ db: Database) throws -> [League] {
		var query = League.all()
			.filter(Column("bowler") == bowler)

		switch ordering {
		case .byName, .byRecentlyUsed:
			query = query.order(Column("name").collating(.localizedCaseInsensitiveCompare))
		}

		return try query.fetchAll(db)
	}
}
