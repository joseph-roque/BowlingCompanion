import AppIconServiceInterface
import AssetsLibrary
import ComposableArchitecture
import FeatureActionLibrary
import StringsLibrary
import SwiftUI

public struct AppIconList: Reducer {
	public struct State: Equatable {
		public var isLoadingAppIcon = true
		public var currentAppIcon: AppIcon?
		@PresentationState var alert: AlertState<Action.Alert>?

		init() {}
	}

	public enum Action: FeatureAction, Equatable {
		public enum ViewAction: Equatable {
			case onAppear
			case didTapIcon(AppIcon)
			case didTapReset
		}
		public enum DelegateAction: Equatable {}
		public enum InternalAction: Equatable {
			case didUpdateIcon(TaskResult<Never>)
			case didFetchIcon(TaskResult<AppIcon?>)
			case alert(PresentationAction<Alert>)
		}
		public enum Alert: Equatable {}

		case view(ViewAction)
		case delegate(DelegateAction)
		case `internal`(InternalAction)
	}

	@Dependency(\.appIcon) var appIcon

	public var body: some ReducerOf<Self> {
		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case .onAppear:
					return fetchCurrentAppIcon()

				case let .didTapIcon(icon):
					guard state.currentAppIcon != icon && !(icon == .primary && state.currentAppIcon == nil) else {
						return .none
					}

					return .concatenate(
						.run { _ in
							if icon == .primary {
								try await appIcon.resetAppIcon()
							} else {
								try await appIcon.setAppIcon(icon)
							}
						} catch: { error, send in
							await send(.internal(.didUpdateIcon(.failure(error))))
						},
						fetchCurrentAppIcon()
					)

				case .didTapReset:
					return .concatenate(
						.run { _ in
							try await appIcon.resetAppIcon()
						} catch: { error, send in
							await send(.internal(.didUpdateIcon(.failure(error))))
						},
						fetchCurrentAppIcon()
					)
				}

			case let .internal(internalAction):
				switch internalAction {
				case let .didFetchIcon(.success(icon)):
					state.isLoadingAppIcon = false
					state.currentAppIcon = icon
					return .none

				case .didFetchIcon(.failure):
					state.alert = AlertState { TextState("Could not find icon. Please try again.") }
					return .none

				case .didUpdateIcon(.failure):
					state.alert = AlertState { TextState("Could not change icon. Please try again.") }
					return .none

				case .alert(.dismiss), .alert(.presented):
					return .none
				}

			case .delegate:
				return .none
			}
		}
		.ifLet(\.$alert, action: /Action.internal..Action.InternalAction.alert)
	}

	private func fetchCurrentAppIcon() -> Effect<Action> {
		.run { send in
			await send(.internal(.didFetchIcon(TaskResult { AppIcon(rawValue: await appIcon.getAppIconName() ?? "") })))
		}
	}
}

public struct AppIconListView: View {
	let store: StoreOf<AppIconList>

	public var body: some View {
		WithViewStore(store, observe: { $0}, content: { viewStore in
			List {
				Section {
					Button { viewStore.send(.view(.didTapReset)) } label: {
						AppIconView(Strings.App.Icon.current, icon: .image(viewStore.appIconImage))
					}
					.buttonStyle(.plain)
				}

				ForEach(AppIcon.Category.allCases) { category in
					Section(String(describing: category)) {
						ForEach(category.matchingIcons) { icon in
							Button { viewStore.send(.view(.didTapIcon(icon))) } label: {
								AppIconView(String(describing: icon), icon: .appIcon(icon))
							}
						}
					}
				}
			}
			.navigationTitle(Strings.Settings.AppIcon.title)
			.onAppear { viewStore.send(.view(.onAppear)) }
			.alert(store: self.store.scope(state: \.$alert, action: { .internal(.alert($0)) }))
		})
	}
}

extension AppIconList.State {
	var appIconImage: UIImage {
		if let currentAppIcon {
			return UIImage(named: currentAppIcon.rawValue) ?? UIImage()
		} else if isLoadingAppIcon {
			return UIImage()
		} else {
			return UIImage(named: "AppIcon") ?? UIImage()
		}
	}
}

extension AppIcon.Category: CustomStringConvertible {
	public var description: String {
		switch self {
		case .pride: return Strings.App.Icon.Category.pride
		case .standard: return Strings.App.Icon.Category.standard
		}
	}
}

extension AppIcon: CustomStringConvertible {
	public var description: String {
		switch self {
		case .bisexual: return Strings.App.Icon.bisexual
		case .earth: return Strings.App.Icon.earth
		case .ember: return Strings.App.Icon.ember
		case .glacial: return Strings.App.Icon.glacial
		case .hexed: return Strings.App.Icon.hexed
		case .pink: return Strings.App.Icon.pink
		case .pride: return Strings.App.Icon.pride
		case .primary: return Strings.App.Icon.primary
		case .sage: return Strings.App.Icon.sage
		case .trans: return Strings.App.Icon.trans
		}
	}
}

// MARK: - Previews

#if DEBUG
struct AppIconListViewPreviews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			AppIconListView(store:
				.init(
					initialState: .init(),
					reducer: { AppIconList() },
					withDependencies: {
						$0.appIcon.getAppIconName = { nil }
					}
				)
			)
		}
	}
}
#endif