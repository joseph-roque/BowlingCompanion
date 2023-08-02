package ca.josephroque.bowlingcompanion.core.database.model

import androidx.compose.runtime.Immutable
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import ca.josephroque.bowlingcompanion.core.model.Lane
import ca.josephroque.bowlingcompanion.core.model.LanePosition
import java.util.UUID

@Entity(
	tableName = "lanes",
	foreignKeys = [
		ForeignKey(
			entity = AlleyEntity::class,
			parentColumns = ["id"],
			childColumns = ["alley_id"],
			onDelete = ForeignKey.CASCADE,
			onUpdate = ForeignKey.CASCADE,
		),
	],
)
@Immutable
data class LaneEntity(
	@PrimaryKey @ColumnInfo(name = "id", index = true) val id: UUID,
	@ColumnInfo(name = "alley_id", index = true) val alleyId: UUID,
	@ColumnInfo(name = "label") val label: String,
	@ColumnInfo(name = "position") val position: LanePosition,
)

fun LaneEntity.asExternalModel() = Lane(
	id = id,
	label = label,
	position = position,
)