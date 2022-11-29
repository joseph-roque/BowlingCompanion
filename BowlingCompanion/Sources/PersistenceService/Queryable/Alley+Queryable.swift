import GRDB
import PersistenceServiceInterface
import SharedPersistenceModelsLibrary
import SharedModelsLibrary

extension Alley.Query: Queryable {
	@Sendable func fetchValues(_ db: Database) throws -> [Alley] {
		var query = Alley.all()

		filter.forEach {
			switch $0 {
			case let .id(id):
				query = query.filter(Column("id") == id)
			case let .material(material):
				query = query.filter(Column("material") == material.rawValue)
			case let .mechanism(mechanism):
				query = query.filter(Column("mechanism") == mechanism.rawValue)
			case let .pinBase(pinBase):
				query = query.filter(Column("pinBase") == pinBase.rawValue)
			case let .pinFall(pinFall):
				query = query.filter(Column("pinFall") == pinFall.rawValue)
			case let .name(name):
				query = query.filter(Column("name") == name)
			}
		}

		switch ordering {
		case .byName:
			query = query.order(Column("name").asc)
		}

		return try query.fetchAll(db)
	}
}
