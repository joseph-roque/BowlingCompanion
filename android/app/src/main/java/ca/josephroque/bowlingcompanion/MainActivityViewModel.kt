package ca.josephroque.bowlingcompanion

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ca.josephroque.bowlingcompanion.core.analytics.AnalyticsClient
import ca.josephroque.bowlingcompanion.core.analytics.trackable.app.AppLaunched
import ca.josephroque.bowlingcompanion.core.analytics.trackable.app.AppTabSwitched
import ca.josephroque.bowlingcompanion.core.data.repository.UserDataRepository
import ca.josephroque.bowlingcompanion.navigation.TopLevelDestination
import ca.josephroque.bowlingcompanion.ui.ApproachAppUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainActivityViewModel @Inject constructor(
	private val analyticsClient: AnalyticsClient,
	userDataRepository: UserDataRepository,
): ViewModel() {
	private val isLaunchComplete: MutableStateFlow<Boolean> = MutableStateFlow(false)

	val mainActivityUiState = combine(
		userDataRepository.userData,
		isLaunchComplete,
	) { userData, isLaunchComplete ->
		MainActivityUiState.Success(
			appState = ApproachAppUiState(
				isOnboardingComplete = userData.isOnboardingComplete,
				destinations = TopLevelDestination.entries,
				badgeCount = if (!userData.hasOpenedAccessoriesTab) {
					mapOf(TopLevelDestination.ACCESSORIES_OVERVIEW to 1)
				} else {
					emptyMap()
				},
			),
			isLaunchComplete = isLaunchComplete,
		)
	}
		.stateIn(
			scope = viewModelScope,
			started = SharingStarted.WhileSubscribed(5_000),
			initialValue = MainActivityUiState.Loading,
		)

	fun didFirstLaunch() {
		if (isLaunchComplete.value) return

		viewModelScope.launch {
			analyticsClient.initialize()
			analyticsClient.trackEvent(AppLaunched)
		}

		isLaunchComplete.value = true
	}

	fun didChangeTab(destination: TopLevelDestination) {
		analyticsClient.trackEvent(AppTabSwitched(destination.name))
	}
}

sealed interface MainActivityUiState {
	data object Loading: MainActivityUiState
	data class Success(
		val appState: ApproachAppUiState,
		val isLaunchComplete: Boolean,
	): MainActivityUiState
}

internal fun MainActivityUiState.isLaunchComplete(): Boolean = when (this) {
	MainActivityUiState.Loading -> false
	is MainActivityUiState.Success -> this.isLaunchComplete
}