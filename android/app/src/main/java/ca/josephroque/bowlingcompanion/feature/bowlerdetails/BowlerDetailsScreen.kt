package ca.josephroque.bowlingcompanion.feature.bowlerdetails

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import ca.josephroque.bowlingcompanion.R
import ca.josephroque.bowlingcompanion.feature.leagueslist.LeaguesListUiState
import ca.josephroque.bowlingcompanion.feature.leagueslist.leaguesList
import ca.josephroque.bowlingcompanion.feature.statisticswidget.ui.StatisticsWidgetPlaceholderCard
import java.util.UUID

@Composable
internal fun BowlerDetailsRoute(
	onEditLeague: (UUID) -> Unit,
	onAddLeague: () -> Unit,
	modifier: Modifier = Modifier,
	viewModel: BowlerDetailsViewModel = hiltViewModel(),
) {
	val bowlerDetailsState by viewModel.bowlerDetailsState.collectAsStateWithLifecycle()
	val leaguesListState by viewModel.leaguesListState.collectAsStateWithLifecycle()

	BowlerDetailsScreen(
		bowlerDetailsState = bowlerDetailsState,
		leaguesListState = leaguesListState,
		onLeagueClick = viewModel::navigateToLeague,
		onAddLeague = onAddLeague,
		editStatisticsWidget = viewModel::editStatisticsWidget,
		modifier = modifier,
	)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun BowlerDetailsScreen(
	bowlerDetailsState: BowlerDetailsUiState,
	leaguesListState: LeaguesListUiState,
	onLeagueClick: (UUID) -> Unit,
	onAddLeague: () -> Unit,
	editStatisticsWidget: () -> Unit,
	modifier: Modifier = Modifier,
) {
	Scaffold(
		topBar = {
			TopAppBar(
				colors = TopAppBarDefaults.topAppBarColors(),
				title = {
					Text(
						text = when (bowlerDetailsState) {
							BowlerDetailsUiState.Loading -> ""
							is BowlerDetailsUiState.Success -> bowlerDetailsState.bowlerName
						},
						maxLines = 1,
						overflow = TextOverflow.Ellipsis,
					)
				},
				actions = {
					IconButton(onClick = onAddLeague) {
						Icon(
							imageVector = Icons.Filled.Add,
							contentDescription = stringResource(R.string.league_list_add)
						)
					}
				},
			)
		}
	) { padding ->
		LazyColumn(
			modifier = modifier
				.fillMaxSize()
				.padding(padding)
		) {
			item {
				StatisticsWidgetPlaceholderCard(onClick = editStatisticsWidget)
			}

			leaguesList(
				leaguesListState = leaguesListState,
				onLeagueClick = onLeagueClick,
			)
		}
	}
}