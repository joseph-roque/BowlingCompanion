import Dependencies
import FileManagerServiceInterface
import GRDB
import PersistenceServiceInterface

extension PersistenceService: DependencyKey {
	public static let liveValue: Self = {
		let dbManager: DatabaseManager
		do {
			try dbManager = DatabaseManager()
		} catch {
			// TODO: should notify user of failure to open DB
			fatalError("Unable to access persistence service, \(error)")
		}

		let modelPersistence = ModelPersistence(writer: dbManager.writer)
		let modelQuerying = ModelQuerying(reader: dbManager.reader)

		return Self(
			createBowler: modelPersistence.create(model:),
			updateBowler: modelPersistence.update(model:),
			deleteBowler: modelPersistence.delete(model:),
			fetchBowlers: modelQuerying.fetchAll(request:),
			observeBowlers: modelQuerying.observeAll(request:),
			createLeague: modelPersistence.create(model:),
			updateLeague: modelPersistence.update(model:),
			deleteLeague: modelPersistence.delete(model:),
			fetchLeagues: modelQuerying.fetchAll(request:),
			observeLeagues: modelQuerying.observeAll(request:),
			createSeries: modelPersistence.create(model:),
			updateSeries: modelPersistence.update(model:),
			deleteSeries: modelPersistence.delete(model:),
			fetchSeries: modelQuerying.fetchAll(request:),
			observeSeries: modelQuerying.observeAll(request:),
			createGame: modelPersistence.create(model:),
			updateGame: modelPersistence.update(model:),
			deleteGame: modelPersistence.delete(model:),
			fetchGames: modelQuerying.fetchAll(request:),
			observeGames: modelQuerying.observeAll(request:),
			updateFrame: modelPersistence.update(model:),
			fetchFrames: modelQuerying.fetchAll(request:),
			observeFrames: modelQuerying.observeAll(request:),
			createAlley: modelPersistence.create(model:),
			updateAlley: modelPersistence.update(model:),
			deleteAlley: modelPersistence.delete(model:),
			fetchAlleys: modelQuerying.fetchAll(request:),
			observeAlleys: modelQuerying.observeAll(request:),
			createGear: modelPersistence.create(model:),
			updateGear: modelPersistence.update(model:),
			deleteGear: modelPersistence.delete(model:),
			fetchGear: modelQuerying.fetchAll(request:),
			observeGear: modelQuerying.observeAll(request:)
		)
	}()
}
