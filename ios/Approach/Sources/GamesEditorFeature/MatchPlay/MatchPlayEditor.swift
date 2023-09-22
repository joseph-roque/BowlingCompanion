import BowlersRepositoryInterface
import ComposableArchitecture
import EquatableLibrary
import FeatureActionLibrary
import FeatureFlagsServiceInterface
import MatchPlaysRepositoryInterface
import ModelsLibrary
import ModelsViewsLibrary
import PickableModelsLibrary
import ResourcePickerLibrary
import StringsLibrary
import SwiftUI
import SwiftUIExtensionsLibrary
import ViewsLibrary

public struct MatchPlayEditor: Reducer {
	public struct State: Equatable {
		public var matchPlay: MatchPlay.Edit
		public let isOpponentsEnabled: Bool

		@PresentationState public var opponentPicker: ResourcePicker<Bowler.Opponent, AlwaysEqual<Void>>.State?

		init(matchPlay: MatchPlay.Edit, isOpponentsEnabled: Bool? = nil) {
			self.matchPlay = matchPlay

			@Dependency(\.featureFlags) var featureFlags
			self.isOpponentsEnabled = isOpponentsEnabled ?? featureFlags.isEnabled(.opponents)
		}
	}

	public enum Action: FeatureAction, Equatable {
		public enum ViewAction: Equatable {
			case didTapOpponent
			case didSetScore(String)
			case didSetResult(MatchPlay.Result?)
			case didTapDeleteButton
		}
		public enum DelegateAction: Equatable {
			case didEditMatchPlay(MatchPlay.Edit?)
		}
		public enum InternalAction: Equatable {
			case opponentPicker(PresentationAction<ResourcePicker<Bowler.Opponent, AlwaysEqual<Void>>.Action>)
		}

		case view(ViewAction)
		case delegate(DelegateAction)
		case `internal`(InternalAction)
	}

	enum CancelID { case savingScore }

	@Dependency(\.bowlers) var bowlers
	@Dependency(\.continuousClock) var clock
	@Dependency(\.dismiss) var dismiss

	public var body: some ReducerOf<Self> {
		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case .didTapOpponent:
					state.opponentPicker = .init(
						selected: Set([state.matchPlay.opponent?.id].compactMap { $0 }),
						query: .init(()),
						limit: 1,
						showsCancelHeaderButton: false
					)
					return .none

				case let .didSetScore(value):
					if let score = Int(value) {
						state.matchPlay.opponentScore = min(max(score, 0), Game.MAXIMUM_SCORE)
					} else {
						state.matchPlay.opponentScore = nil
					}

					return .run { [matchPlay = state.matchPlay] send in
						try await clock.sleep(for: .nanoseconds(NSEC_PER_SEC / 3))
						await send(.delegate(.didEditMatchPlay(matchPlay)))
					}
					.cancellable(id: CancelID.savingScore, cancelInFlight: true)

				case let .didSetResult(result):
					state.matchPlay.result = result
					return .send(.delegate(.didEditMatchPlay(state.matchPlay)))

				case .didTapDeleteButton:
					return .concatenate(
						.send(.delegate(.didEditMatchPlay(nil))),
						.run { _ in await dismiss() }
					)
				}

			case let .internal(internalAction):
				switch internalAction {
				case let .opponentPicker(.presented(.delegate(delegateAction))):
					switch delegateAction {
					case let .didChangeSelection(opponents):
						state.matchPlay.opponent = opponents.first?.summary
						return .send(.delegate(.didEditMatchPlay(state.matchPlay)))
					}

				case .opponentPicker(.dismiss),
						.opponentPicker(.presented(.internal)), .opponentPicker(.presented(.view)):
					return .none
				}

			case .delegate:
				return .none
			}
		}
		.ifLet(\.$opponentPicker, action: /Action.internal..Action.InternalAction.opponentPicker) {
			ResourcePicker { _ in bowlers.opponents(ordering: .byName) }
		}
	}
}

public struct MatchPlayEditorView: View {
	let store: StoreOf<MatchPlayEditor>

	struct ViewState: Equatable {
		let matchPlay: MatchPlay.Edit
		let isOpponentsEnabled: Bool

		init(state: MatchPlayEditor.State) {
			self.matchPlay = state.matchPlay
			self.isOpponentsEnabled = state.isOpponentsEnabled
		}
	}

	public var body: some View {
		WithViewStore(store, observe: ViewState.init, send: { .view($0) }, content: { viewStore in
			Form {
				if viewStore.isOpponentsEnabled {
					Section(Strings.MatchPlay.Editor.Fields.Opponent.title) {
						NavigationButton { viewStore.send(.didTapOpponent) } content: {
							LabeledContent(
								Strings.MatchPlay.Editor.Fields.Opponent.title,
								value: viewStore.matchPlay.opponent?.name ?? Strings.none
							)
						}

						TextField(
							Strings.MatchPlay.Editor.Fields.Opponent.score,
							text: viewStore.binding(
								get: {
									if let score = $0.matchPlay.opponentScore, score > 0 {
										return String(score)
									} else {
										return ""
									}
								},
								send: { .didSetScore($0) }
							)
						)
						.keyboardType(.numberPad)
					}
				}

				Section {
					Picker(
						Strings.MatchPlay.Editor.Fields.Result.title,
						selection: viewStore.binding(get: { $0.matchPlay.result }, send: { .didSetResult($0) })
					) {
						Text("").tag(nil as MatchPlay.Result?)
						ForEach(MatchPlay.Result.allCases) {
							Text(String(describing: $0)).tag(Optional($0))
						}
					}
				}

				Section {
					DeleteButton { viewStore.send(.didTapDeleteButton) }
				}
			}
		})
		.navigationDestination(
			store: store.scope(state: \.$opponentPicker, action: { .internal(.opponentPicker($0)) })
		) { store in
			ResourcePickerView(store: store) {
				Bowler.View($0)
			}
		}
	}
}