package ca.josephroque.bowlingcompanion.core.database.dao

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Transaction
import ca.josephroque.bowlingcompanion.core.database.model.BowlerWithLeagues
import kotlinx.coroutines.flow.Flow
import java.util.UUID

@Dao
interface LeagueDao {
	@Transaction
	@Query("""
		SELECT * FROM bowlers
		WHERE id = :bowlerId
	""")
	abstract fun getBowlerLeagues(bowlerId: UUID): Flow<BowlerWithLeagues>
}