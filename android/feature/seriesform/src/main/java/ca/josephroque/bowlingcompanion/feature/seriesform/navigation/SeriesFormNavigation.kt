package ca.josephroque.bowlingcompanion.feature.seriesform.navigation

import androidx.navigation.NavController
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavOptions
import androidx.navigation.NavType
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import ca.josephroque.bowlingcompanion.core.model.AlleyID
import ca.josephroque.bowlingcompanion.core.model.LeagueID
import ca.josephroque.bowlingcompanion.core.model.SeriesID
import ca.josephroque.bowlingcompanion.core.navigation.NavResultCallback
import ca.josephroque.bowlingcompanion.core.navigation.Route
import ca.josephroque.bowlingcompanion.core.navigation.navigateForResult
import ca.josephroque.bowlingcompanion.feature.seriesform.SeriesFormRoute

fun NavController.navigateToSeriesForm(seriesId: SeriesID, navOptions: NavOptions? = null) {
	this.navigate(Route.EditSeries.createRoute(seriesId), navOptions)
}

fun NavController.navigateToNewSeriesForm(
	leagueId: LeagueID,
	result: NavResultCallback<SeriesID?>,
	navOptions: NavOptions? = null,
) {
	this.navigateForResult(Route.AddSeries.createRoute(leagueId), result, navOptions)
}

fun NavGraphBuilder.seriesFormScreen(
	onDismissWithResult: (SeriesID?) -> Unit,
	onEditAlley: (AlleyID?, NavResultCallback<Set<AlleyID>>) -> Unit,
) {
	composable(
		route = Route.EditSeries.route,
		arguments = listOf(
			navArgument(Route.EditSeries.ARG_SERIES) { type = NavType.StringType },
		),
	) {
		SeriesFormRoute(
			onDismissWithResult = onDismissWithResult,
			onEditAlley = onEditAlley,
		)
	}
	composable(
		route = Route.AddSeries.route,
		arguments = listOf(
			navArgument(Route.AddSeries.ARG_LEAGUE) { type = NavType.StringType },
		),
	) {
		SeriesFormRoute(
			onDismissWithResult = onDismissWithResult,
			onEditAlley = onEditAlley,
		)
	}
}
