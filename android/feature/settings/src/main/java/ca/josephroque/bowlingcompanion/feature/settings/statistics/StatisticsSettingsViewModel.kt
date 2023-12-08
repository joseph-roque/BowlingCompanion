package ca.josephroque.bowlingcompanion.feature.settings.statistics

import androidx.lifecycle.viewModelScope
import ca.josephroque.bowlingcompanion.core.common.viewmodel.ApproachViewModel
import ca.josephroque.bowlingcompanion.core.data.repository.UserDataRepository
import ca.josephroque.bowlingcompanion.feature.settings.ui.statistics.StatisticsSettingsUiAction
import ca.josephroque.bowlingcompanion.feature.settings.ui.statistics.StatisticsSettingsUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class StatisticsSettingsViewModel @Inject constructor(
	private val userDataRepository: UserDataRepository,
): ApproachViewModel<StatisticsSettingsScreenEvent>() {

	private val _settingsState: Flow<StatisticsSettingsUiState> = userDataRepository.userData.map {
		StatisticsSettingsUiState(
			isCountingH2AsH = !it.isCountingH2AsHDisabled,
			isCountingSplitWithBonusAsSplit = !it.isCountingSplitWithBonusAsSplitDisabled,
			isHidingZeroStatistics = !it.isShowingZeroStatistics,
			isHidingWidgetsInBowlersList = it.isHidingWidgetsInBowlersList,
			isHidingWidgetsInLeaguesList = it.isHidingWidgetsInLeaguesList,
		)
	}

	val uiState: StateFlow<StatisticsSettingsScreenUiState> = _settingsState.map {
		StatisticsSettingsScreenUiState.Loaded(it)
	}.stateIn(
		scope = viewModelScope,
		started = SharingStarted.WhileSubscribed(5_000),
		initialValue = StatisticsSettingsScreenUiState.Loading,
	)

	fun handleAction(action: StatisticsSettingsScreenUiAction) {
		when (action) {
			is StatisticsSettingsScreenUiAction.StatisticsSettingsAction -> handleStatisticsSettingsAction(action.action)
		}
	}

	private fun handleStatisticsSettingsAction(action: StatisticsSettingsUiAction) {
		when (action) {
			StatisticsSettingsUiAction.BackClicked -> sendEvent(StatisticsSettingsScreenEvent.Dismissed)
			is StatisticsSettingsUiAction.IsCountingH2AsHToggled -> toggleIsCountingH2AsH(action.newValue)
			is StatisticsSettingsUiAction.IsCountingSplitWithBonusAsSplitToggled -> toggleIsCountingSplitWithBonusAsSplit(action.newValue)
			is StatisticsSettingsUiAction.IsHidingZeroStatisticsToggled -> toggleIsHidingZeroStatistics(action.newValue)
			is StatisticsSettingsUiAction.IsHidingWidgetsInBowlersListToggled -> toggleIsHidingWidgetsInBowlersList(action.newValue)
			is StatisticsSettingsUiAction.IsHidingWidgetsInLeaguesListToggled -> toggleIsHidingWidgetsInLeaguesList(action.newValue)
		}
	}

	private fun toggleIsCountingH2AsH(newValue: Boolean) {
		viewModelScope.launch {
			userDataRepository.setIsCountingH2AsH(newValue)
		}
	}

	private fun toggleIsCountingSplitWithBonusAsSplit(newValue: Boolean) {
		viewModelScope.launch {
			userDataRepository.setIsCountingSplitWithBonusAsSplit(newValue)
		}
	}

	private fun toggleIsHidingZeroStatistics(newValue: Boolean) {
		viewModelScope.launch {
			userDataRepository.setIsHidingZeroStatistics(newValue)
		}
	}

	private fun toggleIsHidingWidgetsInBowlersList(newValue: Boolean) {
		viewModelScope.launch {
			userDataRepository.setIsHidingWidgetsInBowlersList(newValue)
		}
	}

	private fun toggleIsHidingWidgetsInLeaguesList(newValue: Boolean) {
		viewModelScope.launch {
			userDataRepository.setIsHidingWidgetsInLeaguesList(newValue)
		}
	}
}

