package ca.josephroque.bowlingcompanion.feature.settings.ui.statistics

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Divider
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import ca.josephroque.bowlingcompanion.core.designsystem.components.LabeledSwitch
import ca.josephroque.bowlingcompanion.core.designsystem.components.list.ListSectionHeader
import ca.josephroque.bowlingcompanion.feature.settings.ui.R

@Composable
fun StatisticsSettings(
	state: StatisticsSettingsUiState,
	onAction: (StatisticsSettingsUiAction) -> Unit,
	modifier: Modifier = Modifier,
) {
	Column(
		modifier = modifier
			.fillMaxSize()
			.verticalScroll(rememberScrollState()),
	) {
		FrameSettingsSection(
			isCountingH2AsH = state.isCountingH2AsH,
			isCountingSplitWithBonusAsSplit = state.isCountingSplitWithBonusAsSplit,
			onAction = onAction,
		)

		Divider()

		OverallSettingsSection(
			isHidingZeroStatistics = state.isHidingZeroStatistics,
			onAction = onAction,
		)

		Divider()

		WidgetsSettingsSection(
			isHidingWidgetsInBowlersList = state.isHidingWidgetsInBowlersList,
			isHidingWidgetsInLeaguesList = state.isHidingWidgetsInLeaguesList,
			onAction = onAction,
		)
	}
}

@Composable
private fun FrameSettingsSection(
	isCountingH2AsH: Boolean,
	isCountingSplitWithBonusAsSplit: Boolean,
	onAction: (StatisticsSettingsUiAction) -> Unit,
) {
	ListSectionHeader(titleResourceId = R.string.statistics_settings_per_frame)

	LabeledSwitch(
		checked = isCountingH2AsH,
		onCheckedChange = { onAction(StatisticsSettingsUiAction.ToggleIsCountingH2AsH(it)) },
		titleResourceId = R.string.statistics_settings_count_h2_as_h,
	)

	LabeledSwitch(
		checked = isCountingSplitWithBonusAsSplit,
		onCheckedChange = { onAction(StatisticsSettingsUiAction.ToggleIsCountingSplitWithBonusAsSplit(it)) },
		titleResourceId = R.string.statistics_settings_count_s2_as_s,
	)
}

@Composable
private fun OverallSettingsSection(
	isHidingZeroStatistics: Boolean,
	onAction: (StatisticsSettingsUiAction) -> Unit,
) {
	ListSectionHeader(titleResourceId = R.string.statistics_settings_overall)

	LabeledSwitch(
		checked = isHidingZeroStatistics,
		onCheckedChange = { onAction(StatisticsSettingsUiAction.ToggleIsHidingZeroStatistics(it)) },
		titleResourceId = R.string.statistics_settings_hide_zero,
	)
}

@Composable
private fun WidgetsSettingsSection(
	isHidingWidgetsInBowlersList: Boolean,
	isHidingWidgetsInLeaguesList: Boolean,
	onAction: (StatisticsSettingsUiAction) -> Unit,
) {
	ListSectionHeader(titleResourceId = R.string.statistics_settings_widgets)

	LabeledSwitch(
		checked = isHidingWidgetsInBowlersList,
		onCheckedChange = { onAction(StatisticsSettingsUiAction.ToggleIsHidingWidgetsInBowlersList(it)) },
		titleResourceId = R.string.statistics_settings_hide_widgets_in_bowlers,
	)

	LabeledSwitch(
		checked = isHidingWidgetsInLeaguesList,
		onCheckedChange = { onAction(StatisticsSettingsUiAction.ToggleIsHidingWidgetsInLeaguesList(it)) },
		titleResourceId = R.string.statistics_settings_hide_widgets_in_leagues,
	)
}