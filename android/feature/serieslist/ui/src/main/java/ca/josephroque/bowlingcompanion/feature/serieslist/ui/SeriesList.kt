package ca.josephroque.bowlingcompanion.feature.serieslist.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyItemScope
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import ca.josephroque.bowlingcompanion.core.common.utils.simpleFormat
import ca.josephroque.bowlingcompanion.core.designsystem.components.ArchiveDialog
import ca.josephroque.bowlingcompanion.core.designsystem.components.state.DefaultEmptyState
import me.saket.swipe.SwipeAction
import me.saket.swipe.SwipeableActionsBox

@Composable
fun SeriesList(
	state: SeriesListUiState,
	onAction: (SeriesListUiAction) -> Unit,
	modifier: Modifier = Modifier,
	header: (@Composable LazyItemScope.() -> Unit)? = null,
) {
	state.seriesToArchive?.let {
		ArchiveDialog(
			itemName = it.date.simpleFormat(),
			onArchive = { onAction(SeriesListUiAction.ConfirmArchiveClicked) },
			onDismiss = { onAction(SeriesListUiAction.DismissArchiveClicked) },
		)
	}

	LazyColumn(modifier = modifier) {
		if (state.list.isEmpty()) {
			item {
				DefaultEmptyState(
					title = R.string.series_list_empty_title,
					icon = R.drawable.series_list_empty_state,
					message = R.string.series_list_empty_message,
					action = R.string.series_list_add,
					onActionClick = { onAction(SeriesListUiAction.AddSeriesClicked) },
				)
			}
		} else {
			header?.also {
				item {
					it()
				}
			}

			seriesList(
				list = state.list,
				onSeriesClick = { onAction(SeriesListUiAction.SeriesClicked(it.id)) },
				onArchiveSeries = { onAction(SeriesListUiAction.ArchiveSeriesClicked(it)) },
				onEditSeries = { onAction(SeriesListUiAction.EditSeriesClicked(it.id)) },
			)
		}
	}
}

fun LazyListScope.seriesList(
	list: List<SeriesListChartItem>,
	onSeriesClick: (SeriesListChartItem) -> Unit,
	onArchiveSeries: (SeriesListChartItem) -> Unit,
	onEditSeries: (SeriesListChartItem) -> Unit,
) {
	items(
		items = list,
		key = { it.id },
	) { series ->
		val archiveAction = SwipeAction(
			icon = painterResource(ca.josephroque.bowlingcompanion.core.designsystem.R.drawable.ic_archive),
			background = colorResource(ca.josephroque.bowlingcompanion.core.designsystem.R.color.destructive),
			onSwipe = { onArchiveSeries(series) },
		)

		val editAction = SwipeAction(
			icon = rememberVectorPainter(Icons.Default.Edit),
			background = colorResource(ca.josephroque.bowlingcompanion.core.designsystem.R.color.blue_300),
			onSwipe = { onEditSeries(series) },
		)

		SwipeableActionsBox(
			startActions = listOf(archiveAction),
			endActions = listOf(editAction),
		) {
			SeriesRow(
				series = series,
				onClick = { onSeriesClick(series) },
				modifier = Modifier.padding(bottom = 16.dp),
			)
		}
	}
}