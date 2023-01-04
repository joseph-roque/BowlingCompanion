import GRDB
import PersistenceServiceInterface
import SharedModelsLibrary
import SharedModelsFetchableLibrary
import SharedModelsPersistableLibrary

extension Team.FetchRequest: ManyQueryable {
	@Sendable func fetchValues(_ db: Database) throws -> [Team] {
		var query = Team.all()

		switch filter {
		case let .id(id):
			query = query.filter(id: id)
		case let .name(name):
			query = query.filter(Column("name").like(name))
		case .none:
			break
		}

		switch ordering {
		case .byName, .byRecentlyUsed:
			query = query.order(Column("name").asc)
		}

		return try query.fetchAll(db)
	}
}
