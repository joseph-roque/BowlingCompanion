import GRDB
import PersistenceServiceInterface
import SharedPersistenceModelsLibrary
import SharedModelsLibrary

extension Game.Query: Queryable {
	func fetchValues(_ db: Database) throws -> [Game] {
		try Game.all()
			.filter(Column("seriesId") == series)
			.order(Column("ordinal").asc)
			.fetchAll(db)
	}
}
