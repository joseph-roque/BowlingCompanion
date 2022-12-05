import GRDB
import PersistenceServiceInterface
import SharedPersistenceModelsLibrary
import SharedModelsLibrary

extension Lane.Query: Queryable {
	@Sendable func fetchValues(_ db: Database) throws -> [Lane] {
		var query = Lane.all()

		filter.forEach {
			switch $0 {
			case let .id(id):
				query = query.filter(id: id)
			case let .alley(id):
				query = query.filter(Column("alley") == id)
			}
		}

		switch ordering {
		case .byLabel:
			query = query.order(Column("label").asc)
		}

		return try query.fetchAll(db)
	}
}
