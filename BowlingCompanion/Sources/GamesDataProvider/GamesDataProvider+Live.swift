import GamesDataProviderInterface
import GamesPersistenceServiceInterface
import Dependencies
import GRDB
import PersistenceServiceInterface
import SharedModelsLibrary

extension GamesDataProvider: DependencyKey {
	public static let liveValue: Self = {
		return Self(
			create: { game in
				@Dependency(\.persistenceService) var persistenceService: PersistenceService
				@Dependency(\.gamesPersistenceService) var gamesPersistenceService: GamesPersistenceService

				try await persistenceService.write {
					try await $0.write { db in
						try gamesPersistenceService.create(game, db)
					}
				}
			},
			delete: { game in
				@Dependency(\.persistenceService) var persistenceService: PersistenceService
				@Dependency(\.gamesPersistenceService) var gamesPersistenceService: GamesPersistenceService

				try await persistenceService.write {
					try await $0.write { db in
						try gamesPersistenceService.delete(game, db)
					}
				}
			},
			fetchAll: { request in
				@Dependency(\.persistenceService) var persistenceService: PersistenceService
				return .init { continuation in
					Task {
						do {
							let db = persistenceService.reader()
							let observation = ValueObservation.tracking(request.fetchValue(_:))

							for try await games in observation.values(in: db) {
								continuation.yield(games)
							}

							continuation.finish()
						} catch {
							continuation.finish(throwing: error)
						}
					}
				}
			}
		)
	}()
}
