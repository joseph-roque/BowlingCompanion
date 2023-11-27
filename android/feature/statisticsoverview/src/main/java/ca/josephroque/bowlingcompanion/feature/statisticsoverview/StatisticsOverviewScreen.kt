package ca.josephroque.bowlingcompanion.feature.statisticsoverview

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import ca.josephroque.bowlingcompanion.core.common.navigation.NavResultCallback
import ca.josephroque.bowlingcompanion.core.statistics.TrackableFilter
import ca.josephroque.bowlingcompanion.feature.statisticsoverview.ui.StatisticsOverview
import ca.josephroque.bowlingcompanion.feature.statisticsoverview.ui.StatisticsOverviewTopBar
import kotlinx.coroutines.launch
import java.util.UUID

@Composable
internal fun StatisticsOverviewRoute(
	onPickBowler: (UUID?, NavResultCallback<Set<UUID>>) -> Unit,
	onPickLeague: (UUID, UUID?, NavResultCallback<Set<UUID>>) -> Unit,
	onPickSeries: (UUID?, NavResultCallback<Set<UUID>>) -> Unit,
	onPickGame: (UUID?, NavResultCallback<Set<UUID>>) -> Unit,
	onShowStatistics: (TrackableFilter) -> Unit,
	modifier: Modifier = Modifier,
	viewModel: StatisticsOverviewViewModel = hiltViewModel(),
) {
	val statisticsOverviewState by viewModel.uiState.collectAsStateWithLifecycle()

	val lifecycleOwner = LocalLifecycleOwner.current
	LaunchedEffect(Unit) {
		lifecycleOwner.lifecycleScope.launch {
			viewModel.events
				.flowWithLifecycle(lifecycleOwner.lifecycle, Lifecycle.State.STARTED)
				.collect {
					when (it) {
						is StatisticsOverviewScreenEvent.ShowStatistics ->
							onShowStatistics(it.filter)
						is StatisticsOverviewScreenEvent.EditBowler ->
							onPickBowler(it.bowler) { ids ->
								viewModel.handleAction(StatisticsOverviewScreenUiAction.UpdatedBowler(ids.firstOrNull()))
							}
						is StatisticsOverviewScreenEvent.EditLeague ->
							onPickLeague(it.bowler, it.league) { ids ->
								viewModel.handleAction(StatisticsOverviewScreenUiAction.UpdatedLeague(ids.firstOrNull()))
							}
						is StatisticsOverviewScreenEvent.EditSeries ->
							onPickSeries(it.series) { ids ->
								viewModel.handleAction(StatisticsOverviewScreenUiAction.UpdatedSeries(ids.firstOrNull()))
							}
						is StatisticsOverviewScreenEvent.EditGame ->
							onPickGame(it.game) { ids ->
								viewModel.handleAction(StatisticsOverviewScreenUiAction.UpdatedGame(ids.firstOrNull()))
							}
					}
				}
		}
	}

	StatisticsOverviewScreen(
		state = statisticsOverviewState,
		onAction = viewModel::handleAction,
		modifier = modifier,
	)
}

@Composable
private fun StatisticsOverviewScreen(
	state: StatisticsOverviewScreenUiState,
	onAction: (StatisticsOverviewScreenUiAction) -> Unit,
	modifier: Modifier = Modifier,
) {
	Scaffold(
		topBar = {
			StatisticsOverviewTopBar()
		},
	) { padding ->
		when (state) {
			StatisticsOverviewScreenUiState.Loading -> Unit
			is StatisticsOverviewScreenUiState.Loaded -> StatisticsOverview(
				state = state.statisticsOverview,
				onAction = { onAction(StatisticsOverviewScreenUiAction.StatisticsOverviewAction(it)) },
				modifier = modifier.padding(padding),
			)
		}
	}
}