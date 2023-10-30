package ca.josephroque.bowlingcompanion.core.datastore

import androidx.datastore.core.DataStore
import ca.josephroque.bowlingcompanion.core.model.AnalyticsOptInStatus
import ca.josephroque.bowlingcompanion.core.model.UserData
import kotlinx.coroutines.flow.map
import javax.inject.Inject

class ApproachPreferencesDataSource @Inject constructor(
	private val userPreferences: DataStore<UserPreferences>,
) {
	val userData = userPreferences.data
		.map {
			UserData(
				isOnboardingComplete = it.isOnboardingComplete,
				isLegacyMigrationComplete = it.isLegacyMigrationComplete,
				analyticsOptIn = when (it.analyticsOptIn) {
					AnalyticsOptInProto.ANALYTICS_OPT_IN_OPTED_IN,
					AnalyticsOptInProto.UNRECOGNIZED,
					null -> AnalyticsOptInStatus.OPTED_IN
					AnalyticsOptInProto.ANALYTICS_OPT_IN_OPTED_OUT -> AnalyticsOptInStatus.OPTED_OUT
				},
				isCountingH2AsHDisabled = it.isCountingH2AsHDisabled,
				isCountingSplitWithBonusAsSplitDisabled = it.isCountingSplitWithBonusAsSplitDisabled,
				isShowingZeroStatistics = it.isShowingZeroStatistics,
				isHidingWidgetsInBowlersList = it.isHidingWidgetsInBowlersList,
				isHidingWidgetsInLeaguesList = it.isHidingWidgetsInLeaguesList,
				recentlyUsedBowlerIds = it.recentlyUsedAlleyIdsList,
				recentlyUsedLeagueIds = it.recentlyUsedLeagueIdsList,
				recentlyUsedAlleyIds = it.recentlyUsedAlleyIdsList,
				recentlyUsedGearIds = it.recentlyUsedGearIdsList,
			)
		}

	suspend fun setOnboardingComplete(isOnboardingComplete: Boolean) {
		userPreferences.updateData {
			it.copy {
				this.isOnboardingComplete = isOnboardingComplete
			}
		}
	}

	suspend fun setLegacyMigrationComplete(isLegacyMigrationComplete: Boolean) {
		userPreferences.updateData {
			it.copy {
				this.isLegacyMigrationComplete = isLegacyMigrationComplete
			}
		}
	}

	suspend fun setAnalyticsOptInStatus(status: AnalyticsOptInStatus) {
		userPreferences.updateData {
			it.copy {
				this.analyticsOptIn = when (status) {
					AnalyticsOptInStatus.OPTED_IN -> AnalyticsOptInProto.ANALYTICS_OPT_IN_OPTED_IN
					AnalyticsOptInStatus.OPTED_OUT -> AnalyticsOptInProto.ANALYTICS_OPT_IN_OPTED_OUT
				}
			}
		}
	}

	suspend fun setIsCountingH2AsH(enabled: Boolean) {
		userPreferences.updateData {
			it.copy { this.isCountingH2AsHDisabled = !enabled }
		}
	}

	suspend fun setIsCountingSplitWithBonusAsSplit(enabled: Boolean) {
		userPreferences.updateData {
			it.copy { this.isCountingSplitWithBonusAsSplitDisabled = !enabled }
		}
	}

	suspend fun setIsHidingZeroStatistics(isHiding: Boolean) {
		userPreferences.updateData {
			it.copy { this.isShowingZeroStatistics = !isHiding }
		}
	}

	suspend fun setIsHidingWidgetsInBowlersList(isHiding: Boolean) {
		userPreferences.updateData {
			it.copy { this.isHidingWidgetsInBowlersList = isHiding }
		}
	}

	suspend fun setIsHidingWidgetsInLeaguesList(isHiding: Boolean) {
		userPreferences.updateData {
			it.copy { this.isHidingWidgetsInLeaguesList = isHiding }
		}
	}

	suspend fun insertRecentlyUsedBowler(id: String) {
		userPreferences.updateData {
			val recentBowlers = it.recentlyUsedBowlerIdsList.toMutableList()
			recentBowlers.replaceOrInsert(id)

			it.toBuilder()
				.clearRecentlyUsedBowlerIds()
				.addAllRecentlyUsedBowlerIds(recentBowlers)
				.build()
		}
	}

	suspend fun insertRecentlyUsedAlley(id: String) {
		userPreferences.updateData {
			val recentAlleys = it.recentlyUsedAlleyIdsList.toMutableList()
			recentAlleys.replaceOrInsert(id)

			it.toBuilder()
				.clearRecentlyUsedAlleyIds()
				.addAllRecentlyUsedAlleyIds(recentAlleys)
				.build()
		}
	}

	suspend fun insertRecentlyUsedGear(id: String) {
		userPreferences.updateData {
			val recentGear = it.recentlyUsedGearIdsList.toMutableList()
			recentGear.replaceOrInsert(id)

			it.toBuilder()
				.clearRecentlyUsedGearIds()
				.addAllRecentlyUsedGearIds(recentGear)
				.build()
		}
	}

	suspend fun insertRecentlyUsedLeague(id: String) {
		userPreferences.updateData {
			val recentLeagues = it.recentlyUsedLeagueIdsList.toMutableList()
			recentLeagues.replaceOrInsert(id)

			it.toBuilder()
				.clearRecentlyUsedLeagueIds()
				.addAllRecentlyUsedLeagueIds(recentLeagues)
				.build()
		}
	}
}

private fun MutableList<String>.replaceOrInsert(id: String) {
	this.remove(id)
	this.add(0, id)
}