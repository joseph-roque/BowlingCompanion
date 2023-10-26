package ca.josephroque.bowlingcompanion.core.data.repository

import ca.josephroque.bowlingcompanion.core.model.GameDetails
import ca.josephroque.bowlingcompanion.core.model.GameListItem
import kotlinx.coroutines.flow.Flow
import java.util.UUID

interface GamesRepository {
	fun getGameDetails(gameId: UUID): Flow<GameDetails>
	fun getGamesList(seriesId: UUID): Flow<List<GameListItem>>
}