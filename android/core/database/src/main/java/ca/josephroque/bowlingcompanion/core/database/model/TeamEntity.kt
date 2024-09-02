package ca.josephroque.bowlingcompanion.core.database.model

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import ca.josephroque.bowlingcompanion.core.model.Team
import ca.josephroque.bowlingcompanion.core.model.TeamID

@Entity(
	tableName = "teams",
)
data class TeamEntity(
	@PrimaryKey @ColumnInfo(name = "id", index = true) val id: TeamID,
	@ColumnInfo(name = "name") val name: String,
)

fun Team.asEntity() = TeamEntity(
	id = id,
	name = name,
)
