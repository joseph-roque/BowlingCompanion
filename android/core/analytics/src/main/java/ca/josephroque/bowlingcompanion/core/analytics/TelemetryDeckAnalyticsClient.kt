package ca.josephroque.bowlingcompanion.core.analytics

import android.app.Application
import android.content.Context
import android.util.Log
import ca.josephroque.bowlingcompanion.core.common.dispatcher.di.ApplicationScope
import ca.josephroque.bowlingcompanion.core.data.repository.UserDataRepository
import ca.josephroque.bowlingcompanion.core.model.AnalyticsOptInStatus
import com.telemetrydeck.sdk.EnvironmentMetadataProvider
import com.telemetrydeck.sdk.SessionProvider
import com.telemetrydeck.sdk.TelemetryManager
import dagger.hilt.android.qualifiers.ApplicationContext
import java.util.UUID
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class TelemetryDeckAnalyticsClient @Inject constructor(
	@ApplicationContext private val context: Context,
	private val userDataRepository: UserDataRepository,
	@ApplicationScope private val scope: CoroutineScope,
) : AnalyticsClient {
	companion object {
		private const val TAG = "ca.josephroque.bowlingcompanion.TelemetryDeckAnalyticsClient"
	}

	override val optInStatus = userDataRepository.userData
		.map { it.analyticsOptIn }

	private val globalProperties: MutableStateFlow<Map<String, String>> =
		MutableStateFlow(mapOf())

	private val recordedEvents: MutableStateFlow<Map<String, Set<UUID>>> = MutableStateFlow(mapOf())

	override suspend fun initialize() {
		val optInStatus = this.optInStatus.first()
		if (optInStatus == AnalyticsOptInStatus.OPTED_OUT) {
			Log.d(TAG, "Analytics disabled - User opted out")
			TelemetryManager.stop()
			return
		}

		val application = context.applicationContext as? Application
		val appId = BuildConfig.telemetryDeckAppId

		if (appId.isBlank()) {
			Log.d(TAG, "Analytics disabled - AppId unavailable")
			TelemetryManager.stop()
			return
		} else if (application == null) {
			Log.d(TAG, "Analytics disabled - Application unavailable")
			TelemetryManager.stop()
			return
		}

		val builder = TelemetryManager.Builder()
			.appID(appId)
			.showDebugLogs(BuildConfig.DEBUG)
			.providers(
				listOf(
					SessionProvider(),
					EnvironmentMetadataProvider(),
				),
			)

		TelemetryManager.start(application, builder)
	}

	override suspend fun setGlobalProperty(key: String, value: String?) {
		globalProperties.update {
			it.toMutableMap().apply {
				if (value == null) {
					this.remove(key)
				} else {
					this[key] = value
				}
			}
		}
	}

	override fun startNewGameSession() {
		recordedEvents.update { mapOf() }
	}

	override fun trackEvent(event: TrackableEvent) {
		scope.launch {
			val recordedEvents = recordedEvents.value
			if (event is GameSessionTrackableEvent) {
				if (recordedEvents.contains(
						event.name,
					) &&
					recordedEvents[event.name]!!.contains(event.eventId)
				) {
					return@launch
				} else {
					this@TelemetryDeckAnalyticsClient.recordedEvents.update {
						it.toMutableMap().apply {
							val existingEvents = this[event.name] ?: setOf()
							this[event.name] = existingEvents + event.eventId
						}
					}
				}
			}

			val eventPayload = event.payload ?: mapOf()
			val globalProperties = globalProperties.value
			val additionalPayload = globalProperties + eventPayload

			TelemetryManager.queue(signalType = event.name, additionalPayload = additionalPayload)
		}
	}

	override suspend fun setOptInStatus(status: AnalyticsOptInStatus) {
		userDataRepository.setAnalyticsOptInStatus(status)
		when (status) {
			AnalyticsOptInStatus.OPTED_IN -> initialize()
			AnalyticsOptInStatus.OPTED_OUT -> TelemetryManager.stop()
		}
	}
}
