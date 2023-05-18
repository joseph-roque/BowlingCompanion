import AssetsLibrary
import ComposableArchitecture
import DateTimeLibrary
import EquatableLibrary
import FeatureActionLibrary
import GamesRepositoryInterface
import MatchPlaysRepositoryInterface
import ModelsLibrary
import ResourcePickerLibrary
import StringsLibrary
import SwiftUI
import ViewsLibrary

public struct GameDetails: Reducer {
	public struct State: Equatable {
		public var game: Game.Edit

		init(game: Game.Edit) {
			self.game = game
		}
	}

	public enum Action: FeatureAction, Equatable {
		public enum ViewAction: Equatable {
			case didToggleLock
			case didToggleExclude
			case didToggleMatchPlay
			case didSetMatchPlayResult(MatchPlay.Result?)
			case didSetMatchPlayScore(String)
		}
		public enum DelegateAction: Equatable {
			case didRequestOpponentPicker
			case didEditGame
		}
		public enum InternalAction: Equatable {
			case matchPlayUpdateError(AlwaysEqual<Error>)
		}

		case view(ViewAction)
		case delegate(DelegateAction)
		case `internal`(InternalAction)
	}

	enum CancelID { case saveMatchPlay }

	@Dependency(\.matchPlays) var matchPlays
	@Dependency(\.uuid) var uuid

	public var body: some Reducer<State, Action> {
		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case .didToggleLock:
					state.game.locked.toggle()
					return .send(.delegate(.didEditGame))

				case .didToggleExclude:
					state.game.excludeFromStatistics.toggle()
					return .send(.delegate(.didEditGame))

				case let .didSetMatchPlayResult(result):
					state.game.matchPlay?.result = result
					return state.saveMatchPlay()

				case let .didSetMatchPlayScore(string):
					if !string.isEmpty, let score = Int(string) {
						state.game.matchPlay?.opponentScore = score
					} else {
						state.game.matchPlay?.opponentScore = nil
					}
					return state.saveMatchPlay()

				case .didToggleMatchPlay:
					if state.game.matchPlay == nil {
						return createMatchPlay(state: &state)
					} else {
						return deleteMatchPlay(state: &state)
					}
				}

			case let .internal(internalAction):
				switch internalAction {
				case .matchPlayUpdateError:
					// TODO: handle error updating match play
					return .none
				}

			case .delegate:
				return .none
			}
		}
	}

	private func createMatchPlay(state: inout State) -> Effect<Action> {
		let matchPlay = MatchPlay.Edit(gameId: state.game.id, id: uuid())
		state.game.matchPlay = matchPlay
		return .run { send in
			do {
				try await matchPlays.create(matchPlay)
			} catch {
				await send(.internal(.matchPlayUpdateError(.init(error))))
			}
		}
	}

	private func deleteMatchPlay(state: inout State) -> Effect<Action> {
		guard let matchPlay = state.game.matchPlay else { return .none }
		state.game.matchPlay = nil
		return .concatenate(
			.cancel(id: CancelID.saveMatchPlay),
			.run { send in
				do {
					try await matchPlays.delete(matchPlay.id)
				} catch {
					await send(.internal(.matchPlayUpdateError(.init(error))))
				}
			}
		)
	}
}

extension Game.Lock {
	mutating func toggle() {
		switch self {
		case .locked: self = .open
		case .open: self = .locked
		}
	}
}

extension Game.ExcludeFromStatistics {
	mutating func toggle() {
		switch self {
		case .exclude: self = .include
		case .include: self = .exclude
		}
	}
}

// MARK: - View

public struct GameDetailsView: View {
	let store: StoreOf<GameDetails>

	enum ViewAction {
		case didTapBowler
		case didToggleLock
		case didToggleExclude
		case didToggleMatchPlay
		case didSetMatchPlayResult(MatchPlay.Result?)
		case didSetMatchPlayScore(String)
	}

	init(store: StoreOf<GameDetails>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store, observe: { $0 }, send: GameDetails.Action.init, content: { viewStore in
			Section(Strings.MatchPlay.title) {
				Toggle(
					Strings.MatchPlay.record,
					isOn: viewStore.binding(get: { $0.game.matchPlay != nil }, send: ViewAction.didToggleMatchPlay)
				)

				if let matchPlay = viewStore.game.matchPlay {
					Button { viewStore.send(.didTapBowler) } label: {
						HStack {
							LabeledContent(
								Strings.Opponent.title,
								value: viewStore.game.matchPlay?.opponent?.name ?? Strings.none
							)
							Image(systemName: "chevron.forward")
								.resizable()
								.scaledToFit()
								.frame(width: .tinyIcon, height: .tinyIcon)
								.foregroundColor(Color(uiColor: .secondaryLabel))
						}
						.contentShape(Rectangle())
					}
					.buttonStyle(TappableElement())

					TextField(
						Strings.MatchPlay.Properties.opponentScore,
						text: viewStore.binding(
							get: {
								if let score = $0.game.matchPlay?.opponentScore, score > 0 {
									return String(score)
								} else {
									return ""
								}
							},
							send: ViewAction.didSetMatchPlayScore
						)
					)

					Picker(
						Strings.MatchPlay.Properties.result,
						selection: viewStore.binding(get: { _ in matchPlay.result }, send: ViewAction.didSetMatchPlayResult)
					) {
						Text("").tag(nil as MatchPlay.Result?)
						ForEach(MatchPlay.Result.allCases) {
							Text(String(describing: $0)).tag(Optional($0))
						}
					}
				}
			}

			if let alley = viewStore.game.series.alley?.name {
				Section(Strings.Alley.title) {
					LabeledContent(Strings.Alley.Title.bowlingAlley, value: alley)
					LabeledContent(Strings.Lane.List.title, value: viewStore.game.series.laneLabels)
				}
			}

			Section {
				Toggle(
					Strings.Game.Editor.Fields.Lock.label,
					isOn: viewStore.binding(get: { $0.game.locked == .locked }, send: ViewAction.didToggleLock)
				)
			} footer: {
				Text(Strings.Game.Editor.Fields.Lock.help)
			}

			Section {
				Toggle(
					Strings.Game.Editor.Fields.ExcludeFromStatistics.label,
					isOn: viewStore.binding(get: { $0.game.excludeFromStatistics == .exclude }, send: ViewAction.didToggleExclude)
				)
			} footer: {
				// TODO: check if series or league is locked and display different help message
				Text(Strings.Game.Editor.Fields.ExcludeFromStatistics.help)
			}
		})
	}
}

extension GameDetails.State {
	mutating func setMatchPlay(opponent: Bowler.Summary?) -> Effect<GameDetails.Action> {
		game.matchPlay?.opponent = opponent
		return saveMatchPlay()
	}

	mutating func saveMatchPlay() -> Effect<GameDetails.Action> {
		@Dependency(\.matchPlays) var matchPlays
		@Dependency(\.continuousClock) var clock

		guard let matchPlay = game.matchPlay else { return .none }
		return .run { send in
			do {
				try await clock.sleep(for: .nanoseconds(NSEC_PER_SEC / 3))
				try await matchPlays.update(matchPlay)
			} catch {
				await send(.internal(.matchPlayUpdateError(.init(error))))
			}
		}
		.cancellable(id: GameDetails.CancelID.saveMatchPlay)
	}
}

extension GameDetails.Action {
	init(action: GameDetailsView.ViewAction) {
		switch action {
		case .didToggleLock:
			self = .view(.didToggleLock)
		case .didToggleExclude:
			self = .view(.didToggleExclude)
		case .didToggleMatchPlay:
			self = .view(.didToggleMatchPlay)
		case let .didSetMatchPlayResult(result):
			self = .view(.didSetMatchPlayResult(result))
		case let .didSetMatchPlayScore(score):
			self = .view(.didSetMatchPlayScore(score))
		case .didTapBowler:
			self = .delegate(.didRequestOpponentPicker)
		}
	}
}

extension Game.Edit.SeriesInfo {
	var laneLabels: String {
		lanes.isEmpty ? Strings.none : lanes.map(\.label).joined(separator: ", ")
	}
}

extension MatchPlay.Result: CustomStringConvertible {
	public var description: String {
		switch self {
		case .lost: return Strings.MatchPlay.Properties.Result.lost
		case .tied: return Strings.MatchPlay.Properties.Result.tied
		case .won: return Strings.MatchPlay.Properties.Result.won
		}
	}
}
