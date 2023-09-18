import AnalyticsServiceInterface
import ComposableArchitecture
import ConstantsLibrary
import EmailServiceInterface
import FeatureActionLibrary
import FeatureFlagsServiceInterface
import ImportExportFeature
import StringsLibrary
import SwiftUI
import SwiftUIExtensionsLibrary
import ViewsLibrary

public struct HelpSettings: Reducer {
	public struct State: Equatable {
		@BindingState public var isShowingBugReportEmail: Bool = false
		@BindingState public var isShowingSendFeedbackEmail: Bool = false

		@PresentationState public var destination: Destination.State?

		public let isExportEnabled: Bool
		public let isImportEnabled: Bool

		init() {
			@Dependency(\.featureFlags) var featureFlags
			self.isExportEnabled = featureFlags.isEnabled(.dataExport)
			self.isImportEnabled = featureFlags.isEnabled(.dataImport)
		}
	}

	public enum Action: FeatureAction, Equatable {
		public enum ViewAction: BindableAction, Equatable {
			case didTapReportBugButton
			case didTapSendFeedbackButton
			case didShowAcknowledgements
			case didTapAnalyticsButton
			case didShowDeveloperDetails
			case didTapViewSource
			case didTapImportButton
			case didTapExportButton
			case binding(BindingAction<State>)
		}
		public enum DelegateAction: Equatable {}
		public enum InternalAction: Equatable {
			case destination(PresentationAction<Destination.Action>)
		}

		case view(ViewAction)
		case delegate(DelegateAction)
		case `internal`(InternalAction)
	}

	public struct Destination: Reducer {
		public enum State: Equatable {
			case analytics(AnalyticsSettings.State)
			case export(Export.State)
		}

		public enum Action: Equatable {
			case analytics(AnalyticsSettings.Action)
			case export(Export.Action)
		}

		public var body: some ReducerOf<Self> {
			Scope(state: /State.analytics, action: /Action.analytics) {
				AnalyticsSettings()
			}
			Scope(state: /State.export, action: /Action.export) {
				Export()
			}
		}
	}

	@Dependency(\.email) var email
	@Dependency(\.export) var export
	@Dependency(\.openURL) var openURL

	public var body: some ReducerOf<Self> {
		BindingReducer(action: /Action.view)

		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case .didTapReportBugButton:
					return .run { send in
						if await email.canSendEmail() {
							await send(.view(.binding(.set(\.$isShowingBugReportEmail, true))))
						} else {
							guard let mailto = URL(string: "mailto://\(Strings.Settings.Help.ReportBug.email)") else { return }
							await openURL(mailto)
						}
					}

				case .didTapSendFeedbackButton:
					return .run { send in
						if await email.canSendEmail() {
							await send(.view(.binding(.set(\.$isShowingSendFeedbackEmail, true))))
						} else {
							guard let mailto = URL(string: "mailto://\(Strings.Settings.Help.SendFeedback.email)") else { return }
							await openURL(mailto)
						}
					}

				case .didShowAcknowledgements:
					return .none

				case .didShowDeveloperDetails:
					return .none

				case .didTapViewSource:
					return .run { _ in await openURL(AppConstants.openSourceRepositoryUrl) }

				case .didTapAnalyticsButton:
					state.destination = .analytics(.init())
					return .none

				case .didTapImportButton:
					// TODO: Navigate to data import feature
					return .none

				case .didTapExportButton:
					state.destination = .export(.init())
					return .none

				case .binding:
					return .none
				}

			case let .internal(internalAction):
				switch internalAction {
				case let .destination(.presented(.analytics(.delegate(delegateAction)))):
					switch delegateAction {
					case .never:
						return .none
					}

				case let .destination(.presented(.export(.delegate(delegateAction)))):
					switch delegateAction {
					case .never:
						return .none
					}

				case .destination(.dismiss):
					switch state.destination {
					case .export:
						return .run { _ in export.cleanUp() }
					case .analytics, .none:
						return .none
					}

				case .destination(.presented(.analytics(.internal))), .destination(.presented(.analytics(.view))),
						.destination(.presented(.export(.internal))), .destination(.presented(.export(.view))):
					return .none
				}

			case .delegate:
				return .none
			}
		}
		.ifLet(\.$destination, action: /Action.internal..Action.InternalAction.destination) {
			Destination()
		}

		AnalyticsReducer<State, Action> { _, action in
			switch action {
			case .view(.didTapReportBugButton):
				return Analytics.Settings.ReportedBug()
			case .view(.didTapSendFeedbackButton):
				return Analytics.Settings.SentFeedback()
			case .view(.didShowAcknowledgements):
				return Analytics.Settings.ViewedAcknowledgements()
			case .view(.didShowDeveloperDetails):
				return Analytics.Settings.ViewedDeveloper()
			case .view(.didTapViewSource):
				return Analytics.Settings.ViewedSource()
			case .view(.didTapAnalyticsButton):
				return Analytics.Settings.ViewedAnalytics()
			default:
				return nil
			}
		}
	}
}

public struct HelpSettingsView: View {
	let store: StoreOf<HelpSettings>

	struct ViewState: Equatable {
		@BindingState var isShowingBugReportEmail: Bool
		@BindingState var isShowingSendFeedbackEmail: Bool
	}

	public var body: some View {
		WithViewStore(store, observe: { $0 }, send: { .view($0) }, content: { viewStore in
			Section(Strings.Settings.Help.title) {
				Button(Strings.Settings.Help.reportBug) { viewStore.send(.didTapReportBugButton) }
				Button(Strings.Settings.Help.sendFeedback) { viewStore.send(.didTapSendFeedbackButton) }
				NavigationLink(
					Strings.Settings.Help.acknowledgements,
					destination: AcknowledgementsView()
						.onFirstAppear { viewStore.send(.didShowAcknowledgements) }
				)
				Button(Strings.Settings.Analytics.title) { viewStore.send(.didTapAnalyticsButton) }
					.buttonStyle(.navigation)
			}

			if viewStore.isImportEnabled || viewStore.isExportEnabled {
				Section(Strings.Settings.Data.title) {
					if viewStore.isImportEnabled {
						Button(Strings.Settings.Data.import) { viewStore.send(.didTapImportButton) }
							.buttonStyle(.navigation)
					}

					if viewStore.isExportEnabled {
						Button(Strings.Settings.Data.export) { viewStore.send(.didTapExportButton) }
							.buttonStyle(.navigation)
					}
				}
			}

			Section {
				NavigationLink(
					Strings.Settings.Help.developer,
					destination: DeveloperDetailsView()
						.onFirstAppear { viewStore.send(.didShowDeveloperDetails) }
				)
				Button(Strings.Settings.Help.viewSource) { viewStore.send(.didTapViewSource) }
				// FIXME: enable tip jar
//				NavigationLink("Tip Jar", destination: TipJarView())
			} header: {
				Text(Strings.Settings.Help.Development.title)
			} footer: {
				Text(Strings.Settings.Help.Development.help(AppConstants.appName))
			}
			.sheet(isPresented: viewStore.$isShowingBugReportEmail) {
				EmailView(
					content: .init(
						recipients: [Strings.Settings.Help.ReportBug.email],
						subject: Strings.Settings.Help.ReportBug.subject(AppConstants.appVersionReadable)
					)
				)
			}
			.sheet(isPresented: viewStore.$isShowingSendFeedbackEmail) {
				EmailView(
					content: .init(
						recipients: [Strings.Settings.Help.SendFeedback.email]
					)
				)
			}
			.navigationDestination(
				store: store.scope(state: \.$destination, action: { .internal(.destination($0)) }),
				state: /HelpSettings.Destination.State.analytics,
				action: HelpSettings.Destination.Action.analytics
			) {
				AnalyticsSettingsView(store: $0)
			}
			.navigationDestination(
				store: store.scope(state: \.$destination, action: { .internal(.destination($0)) }),
				state: /HelpSettings.Destination.State.export,
				action: HelpSettings.Destination.Action.export
			) {
				ExportView(store: $0)
			}
		})
	}
}

extension HelpSettingsView.ViewState {
	init(store: BindingViewStore<HelpSettings.State>) {
		self._isShowingBugReportEmail = store.$isShowingBugReportEmail
		self._isShowingSendFeedbackEmail = store.$isShowingSendFeedbackEmail
	}
}
