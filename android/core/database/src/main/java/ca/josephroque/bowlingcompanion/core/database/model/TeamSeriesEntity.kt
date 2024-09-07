package ca.josephroque.bowlingcompanion.core.database.model

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import ca.josephroque.bowlingcompanion.core.model.BowlerID
import ca.josephroque.bowlingcompanion.core.model.TeamID
import ca.josephroque.bowlingcompanion.core.model.TeamSeriesCreate
import ca.josephroque.bowlingcompanion.core.model.TeamSeriesID
import kotlinx.datetime.LocalDate

@Entity(
	tableName = "team_series",
	foreignKeys = [
		ForeignKey(
			entity = TeamEntity::class,
			parentColumns = ["id"],
			childColumns = ["team_id"],
			onDelete = ForeignKey.CASCADE,
			onUpdate = ForeignKey.CASCADE,
		),
	],
)
data class TeamSeriesEntity(
	@PrimaryKey @ColumnInfo(name = "id", index = true) val id: TeamSeriesID,
	@ColumnInfo(name = "team_id", index = true) val teamId: TeamID,
	val date: LocalDate,
)

data class TeamSeriesDetailItemEntity(
	val date: LocalDate,
	val score: Int,
	@ColumnInfo(name = "game_index") val gameIndex: Int,
	@ColumnInfo(name = "bowler_id") val bowlerId: BowlerID,
	@ColumnInfo(name = "bowler_name") val bowlerName: String,
)

data class TeamSeriesCreateEntity(
	@ColumnInfo(name = "team_id") val teamId: TeamID,
	val id: TeamSeriesID,
	val date: LocalDate,
)

fun TeamSeriesCreate.asEntity() = TeamSeriesCreateEntity(
	teamId = teamId,
	id = id,
	date = date,
)
