package ca.josephroque.bowlingcompanion.core.database.model

import androidx.room.ColumnInfo
import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import androidx.room.Relation
import ca.josephroque.bowlingcompanion.core.model.ExcludeFromStatistics
import ca.josephroque.bowlingcompanion.core.model.SeriesListProperties
import ca.josephroque.bowlingcompanion.core.model.SeriesPreBowl
import kotlinx.datetime.LocalDate
import java.util.UUID

@Entity(
	tableName = "series",
	foreignKeys = [
		ForeignKey(
			entity = LeagueEntity::class,
			parentColumns = ["id"],
			childColumns = ["league_id"],
			onUpdate = ForeignKey.CASCADE,
			onDelete = ForeignKey.CASCADE,
		),
		ForeignKey(
			entity = AlleyEntity::class,
			parentColumns = ["id"],
			childColumns = ["alley_id"],
			onUpdate = ForeignKey.CASCADE,
			onDelete = ForeignKey.SET_NULL,
		),
	],
)
data class SeriesEntity(
	@PrimaryKey @ColumnInfo(name = "id", index = true) val id: UUID,
	@ColumnInfo(name = "league_id", index = true) val leagueId: UUID,
	@ColumnInfo(name = "date") val date: LocalDate,
	@ColumnInfo(name = "number_of_games") val numberOfGames: Int,
	@ColumnInfo(name = "pre_bowl") val preBowl: SeriesPreBowl,
	@ColumnInfo(name = "exclude_from_statistics") val excludeFromStatistics: ExcludeFromStatistics,
	@ColumnInfo(name = "alley_id", index = true) val alleyId: UUID?
)

data class SeriesCreate(
	@ColumnInfo(name = "league_id") val leagueId: UUID,
	val id: UUID,
	val date: LocalDate,
	@ColumnInfo(name = "number_of_games") val numberOfGames: Int,
	@ColumnInfo(name = "pre_bowl") val preBowl: SeriesPreBowl,
	@ColumnInfo(name = "exclude_from_statistics") val excludeFromStatistics: ExcludeFromStatistics,
)

data class SeriesUpdate(
	val id: UUID,
	val date: LocalDate,
	@ColumnInfo(name = "pre_bowl") val preBowl: SeriesPreBowl,
	@ColumnInfo(name = "exclude_from_statistics") val excludeFromStatistics: ExcludeFromStatistics,
)

data class SeriesDetails(
	@Embedded
	val properties: SeriesDetailsProperties,
	@Relation(
		parentColumn = "id",
		entityColumn = "series_id",
		entity = GameEntity::class,
		projection = ["score"],
	)
	val scores: List<Int>,
)

data class SeriesDetailsProperties(
	val id: UUID,
	val date: LocalDate,
	val total: Int,
	val numberOfGames: Int,
	val preBowl: SeriesPreBowl,
	val excludeFromStatistics: ExcludeFromStatistics,
)

data class SeriesListItem(
	@Embedded
	val properties: SeriesListProperties,
	@Relation(
		parentColumn = "id",
		entityColumn = "series_id",
		entity = GameEntity::class,
		projection = ["score"],
	)
	val scores: List<Int>,
)