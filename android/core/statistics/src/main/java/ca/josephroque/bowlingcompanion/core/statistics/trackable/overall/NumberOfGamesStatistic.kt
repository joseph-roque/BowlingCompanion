package ca.josephroque.bowlingcompanion.core.statistics.trackable.overall

import ca.josephroque.bowlingcompanion.core.model.TrackableGame
import ca.josephroque.bowlingcompanion.core.statistics.R
import ca.josephroque.bowlingcompanion.core.statistics.StatisticCategory
import ca.josephroque.bowlingcompanion.core.statistics.TrackableFilter
import ca.josephroque.bowlingcompanion.core.statistics.TrackablePerGame
import ca.josephroque.bowlingcompanion.core.statistics.TrackablePerGameConfiguration
import ca.josephroque.bowlingcompanion.core.statistics.interfaces.CountingStatistic

data class NumberOfGamesStatistic(
	var numberOfGames: Int = 0,
): TrackablePerGame, CountingStatistic {
	override val titleResourceId = R.string.statistic_title_number_of_games
	override val category = StatisticCategory.OVERALL
	override val isEligibleForNewLabel = false
	override val preferredTrendDirection = null

	override var count: Int
		get() = numberOfGames
		set(value) { numberOfGames = value }

	override fun adjustByGame(game: TrackableGame, configuration: TrackablePerGameConfiguration) {
		if (game.score > 0) {
			numberOfGames += 1
		}
	}

	override fun supportsSource(source: TrackableFilter.Source): Boolean = when (source) {
		is TrackableFilter.Source.Bowler -> true
		is TrackableFilter.Source.League -> true
		is TrackableFilter.Source.Series -> true
		is TrackableFilter.Source.Game -> false
	}
}