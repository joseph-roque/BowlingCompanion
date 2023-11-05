package ca.josephroque.bowlingcompanion.feature.accessoriesoverview.navigation

import androidx.navigation.NavController
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavOptions
import androidx.navigation.compose.composable
import ca.josephroque.bowlingcompanion.feature.accessoriesoverview.AccessoriesRoute
import java.util.UUID

const val accessoriesNavigationRoute = "accessories"

fun NavController.navigateToAccessories(navOptions: NavOptions? = null) {
	this.navigate(accessoriesNavigationRoute, navOptions)
}

fun NavGraphBuilder.accessoriesScreen(
	onAddAlley: () -> Unit,
	onAddGear: () -> Unit,
	onViewAllAlleys: () -> Unit,
	onViewAllGear: () -> Unit,
	onShowAlleyDetails: (UUID) -> Unit,
	onShowGearDetails: (UUID) -> Unit,
) {
	composable(
		route = accessoriesNavigationRoute,
	) {
		AccessoriesRoute(
			onAddAlley = onAddAlley,
			onAddGear = onAddGear,
			onViewAllAlleys = onViewAllAlleys,
			onViewAllGear = onViewAllGear,
			onShowAlleyDetails = onShowAlleyDetails,
			onShowGearDetails = onShowGearDetails,
		)
	}
}