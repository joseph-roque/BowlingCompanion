package ca.josephroque.bowlingcompanion.core.database.model

import androidx.compose.runtime.Immutable
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import ca.josephroque.bowlingcompanion.core.model.Location
import java.util.UUID

@Entity(
	tableName = "locations",
)
@Immutable
data class LocationEntity(
	@PrimaryKey @ColumnInfo(name = "id", index = true) val id: UUID,
	@ColumnInfo(name = "title") val title: String,
	@ColumnInfo(name = "subtitle") val subtitle: String,
	@ColumnInfo(name = "latitude") val latitude: Double,
	@ColumnInfo(name = "longitude") val longitude: Double,
)

fun LocationEntity.asExternalModel() = Location(
	id = id,
	title = title,
	subtitle = subtitle,
	latitude = latitude,
	longitude = longitude,
)

