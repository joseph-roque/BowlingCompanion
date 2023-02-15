import GRDB

struct Migration20221021CreateLeague: Migration {
	static func migrate(_ db: Database) throws {
		try db.create(table: "league") { t in
			t.column("id", .text)
				.primaryKey()
			t.column("bowler", .text)
				.notNull()
				.indexed()
				.references("bowler", onDelete: .cascade)
			t.column("name", .text)
				.notNull()
			t.column("recurrence", .integer)
				.notNull()
			t.column("numberOfGames", .integer)
			t.column("additionalPinfall", .integer)
			t.column("additionalGames", .integer)
			t.column("excludeFromStatistics", .integer)
				.notNull()
			t.column("alley", .text)
				.indexed()
				.references("alley", onDelete: .setNull)
		}
	}
}
