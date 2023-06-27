package ca.josephroque.bowlingcompanion.core.components

import androidx.compose.foundation.layout.RowScope
import androidx.compose.material3.NavigationBarItem
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun RowScope.ApproachNavigationBarItem(
	isSelected: Boolean,
	onClick: () -> Unit,
	icon: @Composable () -> Unit,
	modifier: Modifier = Modifier,
	selectedIcon: @Composable () -> Unit = icon,
	enabled: Boolean = true,
	label: @Composable (() -> Unit)? = null,
	alwaysShowLabel: Boolean = true
) {
	NavigationBarItem(
		selected = isSelected,
		onClick = onClick,
		icon = if (isSelected) selectedIcon else icon,
		modifier = modifier,
		enabled = enabled,
		label = label,
		alwaysShowLabel = alwaysShowLabel
	)
}