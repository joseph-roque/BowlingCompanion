package ca.josephroque.bowlingcompanion.core.statistics.trackable.middlehit

import ca.josephroque.bowlingcompanion.core.model.TrackableFrame
import ca.josephroque.bowlingcompanion.core.model.isHitRightOfMiddle
import ca.josephroque.bowlingcompanion.core.statistics.PreferredTrendDirection
import ca.josephroque.bowlingcompanion.core.statistics.R
import ca.josephroque.bowlingcompanion.core.statistics.StatisticCategory
import ca.josephroque.bowlingcompanion.core.statistics.TrackableFilter
import ca.josephroque.bowlingcompanion.core.statistics.TrackablePerFirstRoll
import ca.josephroque.bowlingcompanion.core.statistics.TrackablePerFrameConfiguration
import ca.josephroque.bowlingcompanion.core.statistics.interfaces.FirstRollStatistic

data class RightOfMiddleHitsStatistic(
	var rightOfMiddleHits: Int = 0,
	override var totalRolls: Int = 0,
): TrackablePerFirstRoll, FirstRollStatistic {
	override val titleResourceId = R.string.statistic_title_right_of_middle_hits
	override val category = StatisticCategory.MIDDLE_HITS
	override val isEligibleForNewLabel = false
	override val preferredTrendDirection = PreferredTrendDirection.DOWNWARDS

	override var numerator: Int
		get() = rightOfMiddleHits
		set(value) { rightOfMiddleHits = value }

	override fun tracksRoll(
		firstRoll: TrackableFrame.Roll,
		configuration: TrackablePerFrameConfiguration
	): Boolean {
		return firstRoll.pinsDowned.isHitRightOfMiddle()
	}

	override fun supportsSource(source: TrackableFilter.Source): Boolean = when (source) {
		is TrackableFilter.Source.Bowler -> true
		is TrackableFilter.Source.League -> true
		is TrackableFilter.Source.Series -> true
		is TrackableFilter.Source.Game -> true
	}
}