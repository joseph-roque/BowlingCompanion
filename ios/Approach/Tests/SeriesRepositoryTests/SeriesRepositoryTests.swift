import DatabaseModelsLibrary
@testable import DatabaseService
import Dependencies
import GRDB
@testable import ModelsLibrary
import RecentlyUsedServiceInterface
@testable import SeriesRepository
@testable import SeriesRepositoryInterface
import TestUtilitiesLibrary
import XCTest

@MainActor
final class SeriesRepositoryTests: XCTestCase {
	let bowlerId1 = UUID(uuidString: "00000000-0000-0000-0000-00000000001A")!

	let leagueId1 = UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!
	let leagueId2 = UUID(uuidString: "00000000-0000-0000-0000-00000000000B")!

	let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
	let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
	let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

	// MARK: List

	func testList_ReturnsAllSeries() async throws {
		// Given a database with two series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let series2 = Series.Database.mock(id: id2, date: Date(timeIntervalSince1970: 123_456_000))
		let db = try await initializeDatabase(inserting: [series1, series2])

		// Fetching the series
		let series = withDependencies {
			$0.database.reader = { db }
		} operation: {
			SeriesRepository.liveValue.list(bowledIn: leagueId1, ordering: .byDate)
		}
		var iterator = series.makeAsyncIterator()
		let fetched = try await iterator.next()

		// Returns all the series
		XCTAssertEqual(fetched, [.init(series1), .init(series2)])
	}

	func testList_FilterByLeague_ReturnsLeagueSeries() async throws {
		// Given a database with two series
		let series1 = Series.Database.mock(leagueId: leagueId1, id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let series2 = Series.Database.mock(leagueId: leagueId2, id: id2, date: Date(timeIntervalSince1970: 123_456_000))
		let db = try await initializeDatabase(inserting: [series1, series2])

		// Fetching the series by league
		let series = withDependencies {
			$0.database.reader = { db }
		} operation: {
			SeriesRepository.liveValue.list(bowledIn: leagueId1, ordering: .byDate)
		}
		var iterator = series.makeAsyncIterator()
		let fetched = try await iterator.next()

		// Returns one series
		XCTAssertEqual(fetched, [.init(series1)])
	}

	func testList_SortsByDate() async throws {
		// Given a database with three series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let series2 = Series.Database.mock(id: id2, date: Date(timeIntervalSince1970: 123_456_002))
		let series3 = Series.Database.mock(id: id3, date: Date(timeIntervalSince1970: 123_456_000))
		let db = try await initializeDatabase(inserting: [series1, series2, series3])

		// Fetching the series
		let series = withDependencies {
			$0.database.reader = { db }
		} operation: {
			SeriesRepository.liveValue.list(bowledIn: leagueId1, ordering: .byDate)
		}
		var iterator = series.makeAsyncIterator()
		let fetched = try await iterator.next()

		// Returns all the series sorted by date
		XCTAssertEqual(fetched, [.init(series2), .init(series1), .init(series3)])
	}

	// MARK: Create

	func testCreate_WhenSeriesExists_ThrowsError() async throws {
		// Given a database with an existing series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let db = try await initializeDatabase(inserting: [series1])

		// Creating the series throws an error
		await assertThrowsError(ofType: DatabaseError.self) {
			let create = Series.Create(
				leagueId: leagueId1,
				id: id1,
				date: Date(timeIntervalSince1970: 123_456_002),
				preBowl: .regular,
				excludeFromStatistics: .exclude,
				numberOfGames: 1
			)
			try await withDependencies {
				$0.database.writer = { db }
			} operation: {
				try await SeriesRepository.liveValue.create(create)
			}
		}

		// Does not insert any records
		let count = try await db.read { try Series.Database.fetchCount($0) }
		XCTAssertEqual(count, 1)

		// Does not update the database
		let updated = try await db.read { try Series.Database.fetchOne($0, id: self.id1) }
		XCTAssertEqual(updated?.id, id1)
		XCTAssertEqual(updated?.date, Date(timeIntervalSince1970: 123_456_001))
	}

	func testCreate_WhenSeriesNotExists_CreatesSeries() async throws {
		// Given a database with no series
		let db = try await initializeDatabase()

		// Creating the series throws an error
		let create = Series.Create(
			leagueId: leagueId1,
			id: id1,
			date: Date(timeIntervalSince1970: 123_456_001),
			preBowl: .regular,
			excludeFromStatistics: .exclude,
			numberOfGames: 1
		)
		try await withDependencies {
			$0.database.writer = { db }
		} operation: {
			try await SeriesRepository.liveValue.create(create)
		}

		// Inserted the record
		let exists = try await db.read { try Series.Database.exists($0, id: self.id1) }
		XCTAssertTrue(exists)

		// Updates the database
		let updated = try await db.read { try Series.Database.fetchOne($0, id: self.id1) }
		XCTAssertEqual(updated?.id, id1)
		XCTAssertEqual(updated?.date, Date(timeIntervalSince1970: 123_456_001))
	}

	// MARK: Update

	func testUpdate_WhenSeriesExists_UpdatesSeries() async throws {
		// Given a database with an existing series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let db = try await initializeDatabase(inserting: [series1])

		// Editing the series
		let editable = Series.Edit(
			leagueId: leagueId1,
			id: id1,
			numberOfGames: series1.numberOfGames,
			date: Date(timeIntervalSince1970: 123_456_999),
			preBowl: .regular,
			excludeFromStatistics: series1.excludeFromStatistics,
			location: nil
		)
		try await withDependencies {
			$0.database.writer = { db }
		} operation: {
			try await SeriesRepository.liveValue.update(editable)
		}

		// Updates the database
		let updated = try await db.read { try Series.Database.fetchOne($0, id: self.id1) }
		XCTAssertEqual(updated?.id, id1)
		XCTAssertEqual(updated?.date, Date(timeIntervalSince1970: 123_456_999))

		// Does not insert any records
		let count = try await db.read { try Series.Database.fetchCount($0) }
		XCTAssertEqual(count, 1)
	}

	func testUpdate_WhenSeriesNotExists_ThrowsError() async throws {
		// Given a database with no series
		let db = try await initializeDatabase(inserting: [])

		// Updating a series
		let editable = Series.Edit(
			leagueId: leagueId1,
			id: id1,
			numberOfGames: 4,
			date: Date(timeIntervalSince1970: 123_456_999),
			preBowl: .regular,
			excludeFromStatistics: .exclude,
			location: nil
		)
		await assertThrowsError(ofType: RecordError.self) {
			try await withDependencies {
				$0.database.writer = { db }
			} operation: {
				try await SeriesRepository.liveValue.update(editable)
			}
		}

		// Does not insert any records
		let count = try await db.read { try Series.Database.fetchCount($0) }
		XCTAssertEqual(count, 0)
	}

	// MARK: Edit

	func testEdit_WhenSeriesExists_ReturnsSeries() async throws {
		// Given a database with one series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_000))
		let db = try await initializeDatabase(inserting: [series1])

		// Editing the series
		let series = try await withDependencies {
			$0.database.reader = { db }
		} operation: {
			try await SeriesRepository.liveValue.edit(id1)
		}

		// Returns the series
		XCTAssertEqual(
			series,
			.init(
				leagueId: leagueId1,
				id: id1,
				numberOfGames: 4,
				date: Date(timeIntervalSince1970: 123_456_000),
				preBowl: .regular,
				excludeFromStatistics: .include,
				location: nil
			)
		)
	}

	func testEdit_WhenSeriesNotExists_ReturnsNil() async throws {
		// Given a database with no series
		let db = try await initializeDatabase(inserting: [])

		// Editing the series
		let series = try await withDependencies {
			$0.database.reader = { db }
		} operation: {
			try await SeriesRepository.liveValue.edit(id1)
		}

		// Returns nil
		XCTAssertNil(series)
	}

	// MARK: Delete

	func testDelete_WhenIdExists_DeletesSeries() async throws {
		// Given a database with 2 series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let series2 = Series.Database.mock(id: id2, date: Date(timeIntervalSince1970: 123_456_000))
		let db = try await initializeDatabase(inserting: [series1, series2])

		// Deleting the first series
		try await withDependencies {
			$0.database.writer = { db }
		} operation: {
			try await SeriesRepository.liveValue.delete(self.id1)
		}

		// Updates the database
		let deletedExists = try await db.read { try Series.Database.exists($0, id: self.id1) }
		XCTAssertFalse(deletedExists)

		// And leaves the other series intact
		let otherExists = try await db.read { try Series.Database.exists($0, id: self.id2) }
		XCTAssertTrue(otherExists)
	}

	func testDelete_WhenIdNotExists_DoesNothing() async throws {
		// Given a database with 1 series
		let series1 = Series.Database.mock(id: id1, date: Date(timeIntervalSince1970: 123_456_001))
		let db = try await initializeDatabase(inserting: [series1])

		// Deleting a non-existent series
		try await withDependencies {
			$0.database.writer = { db }
		} operation: {
			try await SeriesRepository.liveValue.delete(self.id2)
		}

		// Leaves the series
		let exists = try await db.read { try Series.Database.exists($0, id: self.id1) }
		XCTAssertTrue(exists)
	}

	private func initializeDatabase(
		inserting series: [Series.Database] = []
	) async throws -> any DatabaseWriter {
		let dbQueue = try DatabaseQueue()
		var migrator = DatabaseMigrator()
		try migrator.prepare(dbQueue)

		let bowler = Bowler.Database(id: bowlerId1, name: "Joseph", status: .playable)

		let leagues = [
			League.Database(
				bowlerId: bowlerId1,
				id: leagueId1,
				name: "Majors",
				recurrence: .repeating,
				numberOfGames: 4,
				additionalPinfall: nil,
				additionalGames: nil,
				excludeFromStatistics: .include,
				alleyId: nil
			),
			League.Database(
				bowlerId: bowlerId1,
				id: leagueId2,
				name: "Minors",
				recurrence: .repeating,
				numberOfGames: 4,
				additionalPinfall: nil,
				additionalGames: nil,
				excludeFromStatistics: .include,
				alleyId: nil
			),
		]

		try await dbQueue.write {
			try bowler.insert($0)
			for league in leagues {
				try league.insert($0)
			}
			for series in series {
				try series.insert($0)
			}
		}

		return dbQueue
	}
}

extension Series.Database {
	static func mock(
		leagueId: League.ID = UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!,
		id: ID,
		date: Date,
		numberOfGames: Int = 4,
		preBowl: Series.PreBowl = .regular,
		excludeFromStatistics: Series.ExcludeFromStatistics = .include,
		alleyId: Alley.ID? = nil
	) -> Self {
		.init(
			leagueId: leagueId,
			id: id,
			date: date,
			numberOfGames: numberOfGames,
			preBowl: preBowl,
			excludeFromStatistics: excludeFromStatistics,
			alleyId: alleyId
		)
	}
}

extension Series.Summary {
	init(_ from: Series.Database) {
		self.init(
			id: from.id,
			date: from.date
		)
	}
}
