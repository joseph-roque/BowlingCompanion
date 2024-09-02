package ca.josephroque.bowlingcompanion.core.model

import android.os.Parcelable
import java.util.UUID
import kotlinx.datetime.LocalDate
import kotlinx.parcelize.Parcelize

@JvmInline
@Parcelize
value class TeamSeriesID(val value: UUID) : Parcelable {
	override fun toString(): String = value.toString()
	companion object {
		fun randomID(): TeamSeriesID = TeamSeriesID(UUID.randomUUID())
		fun fromString(string: String): TeamSeriesID = TeamSeriesID(UUID.fromString(string))
	}
}

data class TeamSeriesSummary(val id: TeamSeriesID, val date: LocalDate)

data class TeamSeriesDetails(val summary: TeamSeriesSummary, val scores: List<Int>)

data class TeamMemberSeriesSummary(val id: TeamSeriesID, val teamMemberName: String)

data class TeamMemberSeriesDetails(val summary: TeamMemberSeriesSummary, val scores: List<Int>)

data class TeamSeriesListItem(
	val teamSeries: TeamSeriesDetails,
	val memberSeries: List<TeamMemberSeriesDetails>,
)

data class TeamSeriesConnect(
	val id: TeamSeriesID,
	val teamId: TeamID,
	val seriesIds: List<SeriesID>,
	val date: LocalDate,
)

data class TeamSeriesCreate(
	val teamId: TeamID,
	val id: TeamSeriesID,
	val leagues: List<LeagueID>,
	val date: LocalDate,
	val numberOfGames: Int,
	val preBowl: SeriesPreBowl,
	val manualScores: Map<LeagueID, List<Int>>?,
	val excludeFromStatistics: ExcludeFromStatistics,
	val alleyId: AlleyID?,
)
