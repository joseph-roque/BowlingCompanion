package ca.josephroque.bowlingcompanion.core.database.model

import androidx.compose.runtime.Immutable
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import java.util.UUID

@Entity(
	tableName = "frames",
	primaryKeys = ["game_id", "index"],
	foreignKeys = [
		ForeignKey(
			entity = GameEntity::class,
			parentColumns = ["id"],
			childColumns = ["game_id"],
			onDelete = ForeignKey.CASCADE,
			onUpdate = ForeignKey.CASCADE,
		),
		ForeignKey(
			entity = GearEntity::class,
			parentColumns = ["id"],
			childColumns = ["ball0"],
			onDelete = ForeignKey.CASCADE,
			onUpdate = ForeignKey.CASCADE,
		),
		ForeignKey(
			entity = GearEntity::class,
			parentColumns = ["id"],
			childColumns = ["ball1"],
			onDelete = ForeignKey.CASCADE,
			onUpdate = ForeignKey.CASCADE,
		),
		ForeignKey(
			entity = GearEntity::class,
			parentColumns = ["id"],
			childColumns = ["ball2"],
			onDelete = ForeignKey.CASCADE,
			onUpdate = ForeignKey.CASCADE,
		),
	],
	indices = [
		Index("game_id", "index"),
	]
)
@Immutable
data class FrameEntity(
	@ColumnInfo(name = "game_id", index = true) val gameId: UUID,
	@ColumnInfo(name = "index", index = true) val index: Int,
	@ColumnInfo(name = "roll0") val roll0: String?,
	@ColumnInfo(name = "roll1") val roll1: String?,
	@ColumnInfo(name = "roll2") val roll2: String?,
	@ColumnInfo(name = "ball0", index = true) val ball0: UUID?,
	@ColumnInfo(name = "ball1", index = true) val ball1: UUID?,
	@ColumnInfo(name = "ball2", index = true) val ball2: UUID?,
)