package ca.josephroque.bowlingcompanion.feature.gameslist

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ca.josephroque.bowlingcompanion.R
import ca.josephroque.bowlingcompanion.core.model.GameListItem
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GameItemRow(
	game: GameListItem,
	onClick: () -> Unit,
	modifier: Modifier = Modifier,
) {
	Card(
		onClick = onClick,
		colors = CardDefaults.cardColors(
			containerColor = colorResource(R.color.purple_100)
		),
		modifier = modifier,
	) {
		Row(
			verticalAlignment = Alignment.CenterVertically,
			horizontalArrangement = Arrangement.SpaceBetween,
			modifier = Modifier
				.fillMaxWidth()
				.padding(16.dp),
		) {
			Text(
				stringResource(R.string.game_with_ordinal, game.index + 1),
				fontSize = 18.sp,
				fontWeight = FontWeight.Bold,
			)
			Text(
				game.score.toString(),
				fontSize = 16.sp,
			)
		}
	}
}

@Preview
@Composable
fun GameItemPreview() {
	Surface {
		GameItemRow(
			game = GameListItem(
				id = UUID.randomUUID(),
				index = 0,
				score = 234,
			),
			onClick = {},
		)
	}
}