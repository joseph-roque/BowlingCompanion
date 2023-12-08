package ca.josephroque.bowlingcompanion.core.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import ca.josephroque.bowlingcompanion.core.database.model.MatchPlayCreateEntity
import ca.josephroque.bowlingcompanion.core.database.model.MatchPlayDetailsUpdateEntity
import ca.josephroque.bowlingcompanion.core.database.model.MatchPlayEntity
import ca.josephroque.bowlingcompanion.core.database.model.MatchPlayUpdateEntity
import kotlinx.coroutines.flow.Flow
import java.util.UUID

@Dao
abstract class MatchPlayDao: LegacyMigratingDao<MatchPlayEntity> {
	@Transaction
	@Query(
		"""
		SELECT
		  match_plays.id AS id,
			match_plays.opponent_id AS opponentId,
			match_plays.opponent_score AS opponentScore,
			match_plays.result AS result
		FROM match_plays 
		WHERE game_id = :gameId
		"""
	)
	abstract fun getMatchPlayForGame(gameId: UUID): Flow<MatchPlayUpdateEntity?>

	@Insert(entity = MatchPlayEntity::class)
	abstract fun insertMatchPlay(matchPlay: MatchPlayCreateEntity)

	@Update(entity = MatchPlayEntity::class)
	abstract fun updateMatchPlay(matchPlay: MatchPlayDetailsUpdateEntity)

	@Query("DELETE FROM match_plays WHERE id = :matchPlayId")
	abstract fun deleteMatchPlay(matchPlayId: UUID)

	@Query("SELECT * FROM match_plays WHERE game_id IN (:gameIds)")
	abstract suspend fun getMatchPlaysForGames(gameIds: Collection<UUID>): List<MatchPlayEntity>
}