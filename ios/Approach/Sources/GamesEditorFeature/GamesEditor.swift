import ComposableArchitecture
import Dependencies
import FeatureActionLibrary
import Foundation
import FramesRepositoryInterface
import GamesRepositoryInterface
import ModelsLibrary
import ScoreSheetFeature
import ScoringServiceInterface
import SwiftUI

public struct GamesEditor: Reducer {
	public struct State: Equatable {
		public var sheet: SheetState = .presenting(.gameDetails)
		public var sheetDetent: PresentationDetent = .height(.zero)
		public var willAdjustLaneLayoutAt: Date
		public var backdropSize: CGSize = .zero

		public var bowlers: IdentifiedArrayOf<Bowler.Summary>
		public var bowlerGames: [Bowler.ID: [Game.ID]]
		public var frames: [Frame.Edit]?
		public var scoreSteps: [ScoreStep]?

		public var currentBowlerId: Bowler.ID
		public var currentGameId: Game.ID
		public var currentGame: Game.Edit?
		public var currentFrameIndex = 0
		public var currentRollIndex = 0

		public var isScoreSheetVisible = true

		public var _frameEditor: FrameEditor.State?
		public var _rollEditor: RollEditor.State?
		public var _ballPicker: BallPicker.State

		public init(
			bowlers: IdentifiedArrayOf<Bowler.Summary>,
			bowlerGames: [Bowler.ID: [Game.ID]],
			currentBowler: Bowler.ID,
			currentGame: Game.ID
		) {
			precondition(bowlers[id: currentBowler] != nil)
			precondition(bowlerGames[currentBowler]?.contains(currentGame) == true)
			precondition(bowlerGames.allSatisfy { $0.value.count == bowlerGames.first!.value.count })
			self.bowlers = bowlers
			self.bowlerGames = bowlerGames
			self.currentBowlerId = currentBowler
			self.currentGameId = currentGame
			self._ballPicker = .init(forBowler: currentBowler, selected: nil)

			@Dependency(\.date) var date
			self.willAdjustLaneLayoutAt = date()
		}
	}

	public enum Action: FeatureAction, Equatable {
		public enum ViewAction: Equatable {
			case didAppear
			case didChangeDetent(PresentationDetent)
			case didAdjustBackdropSize(CGSize)
			case didDismissOpenSheet
			case setGamePicker(isPresented: Bool)
			case setGameDetails(isPresented: Bool)
			case setBallPicker(isPresented: Bool)
			case setGamesSettings(isPresented: Bool)
		}
		public enum DelegateAction: Equatable {}
		public enum InternalAction: Equatable {
			case switchToBowler(Bowler.ID)
			case switchToGame(Game.ID)
			case framesResponse(TaskResult<[Frame.Edit]>)
			case gameReponse(TaskResult<Game.Edit?>)
			case calculatedScore([ScoreStep])
			case adjustBackdrop

			case gamesSettings(GamesSettings.Action)
			case gamesHeader(GamesHeader.Action)
			case gameDetailsHeader(GameDetailsHeader.Action)
			case gameDetails(GameDetails.Action)
			case gamePicker(GamePicker.Action)
			case frameEditor(FrameEditor.Action)
			case rollEditor(RollEditor.Action)
			case scoreSheet(ScoreSheet.Action)
			case ballPicker(BallPicker.Action)
		}

		case view(ViewAction)
		case delegate(DelegateAction)
		case `internal`(InternalAction)
	}

	struct CancelObservationID {}

	public init() {}

	@Dependency(\.continuousClock) var clock
	@Dependency(\.date) var date
	@Dependency(\.frames) var frames
	@Dependency(\.games) var games
	@Dependency(\.scoringService) var scoringService

	public var body: some Reducer<State, Action> {
		Scope(state: \.gamesHeader, action: /Action.internal..Action.InternalAction.gamesHeader) {
			GamesHeader()
		}

		Scope(state: \.gamePicker, action: /Action.internal..Action.InternalAction.gamePicker) {
			GamePicker()
		}

		Scope(state: \.ballPicker, action: /Action.internal..Action.InternalAction.ballPicker) {
			BallPicker()
		}

		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case .didAppear:
					return loadGameDetails(for: state.currentGameId)

				case let .didAdjustBackdropSize(newSize):
					state.backdropSize = newSize
					switch state.sheetDetent {
					case .large, .medium:
						state.isScoreSheetVisible = false
					default:
						state.isScoreSheetVisible = true
					}
					return .none

				case let .didChangeDetent(newDetent):
					state.sheetDetent = newDetent
					return .task {
						try await clock.sleep(for: .milliseconds(25))
						return .internal(.adjustBackdrop)
					}

				case .didDismissOpenSheet:
					state.sheet.finishTransition()
					return .none

				case let .setGameDetails(isPresented):
					state.sheet.handle(isPresented: isPresented, for: .gameDetails)
					return .none

				case let .setGamePicker(isPresented):
					state.sheet.handle(isPresented: isPresented, for: .gamePicker)
					return .none

				case let .setBallPicker(isPresented):
					state.sheet.handle(isPresented: isPresented, for: .ballPicker)
					return .none

				case let .setGamesSettings(isPresented):
					state.sheet.handle(isPresented: isPresented, for: .settings)
					return .none
				}

			case let .internal(internalAction):
				switch internalAction {
				case let .switchToBowler(bowlerId):
					let gameIndex = state.bowlerGames[state.currentBowlerId]!.firstIndex(of: state.currentGameId)!
					state.currentBowlerId = bowlerId
					state.currentGameId = state.bowlerGames[bowlerId]![gameIndex]
					return loadGameDetails(for: state.currentGameId)

				case let .switchToGame(gameId):
					precondition(state.bowlerGames[state.currentBowlerId]!.contains(gameId))
					state.currentGameId = gameId
					return loadGameDetails(for: state.currentGameId)

				case let .gameReponse(.success(game)):
					guard state.currentGameId == game?.id else { return .none }
					state.currentGame = game
					return .none

				case let .framesResponse(.success(frames)):
					guard frames.first?.gameId == state.currentGameId else {
						// TODO: log error that unexpected frames loaded (should be cancelled in flight)
						return .none
					}

					// TODO: determine which frame and roll to start with
					state.currentFrameIndex = 0
					state.currentRollIndex = 0

					state.frames = frames
					state.frames![state.currentFrameIndex].guaranteeRollExists(upTo: state.currentRollIndex)
					state._frameEditor = .init(currentRollIndex: state.currentRollIndex, frame: state.frames![state.currentFrameIndex])

					// TODO: get initial ball rolled loaded from frame
					state._rollEditor = .init(
						ballRolled: nil,// TODO: state.frames![state.currentFrameIndex].rolls[state.currentRollIndex].roll.ballRolled,
						didFoul: state.frames![state.currentFrameIndex].rolls[state.currentRollIndex].roll.didFoul
					)
					return updateScoreSheet(from: state)

				case .framesResponse(.failure):
					// TODO: handle error loading frames
					return .none

				case .gameReponse(.failure):
					// TODO: handle error loading game
					return .none

				case let .calculatedScore(steps):
					state.scoreSteps = steps
					return .none

				case .adjustBackdrop:
					state.willAdjustLaneLayoutAt = date()
					return .none

				case let .gamePicker(.delegate(delegateAction)):
					switch delegateAction {
					case .didFinish:
						state.sheet.hide(.gamePicker)
						return .none
					}

				case let .ballPicker(.delegate(delegateAction)):
					switch delegateAction {
					case .didFinish:
						state.sheet.hide(.ballPicker)
						return .none
					}

				case let .frameEditor(.delegate(delegateAction)):
					switch delegateAction {
					case .didEditFrame:
						return updateScoreSheet(from: state)
					}

				case let .scoreSheet(.delegate(delegateAction)):
					switch delegateAction {
					case .never:
						return .none
					}

				case let .rollEditor(.delegate(delegateAction)):
					switch delegateAction {
					case .didTapBall:
						state.sheet.transition(to: .ballPicker)
						return .none

					case .didEditRoll:
						return updateScoreSheet(from: state)
					}

				case let .gamesHeader(.delegate(delegateAction)):
					switch delegateAction {
					case .didCloseEditor:
						// TODO: close the games editor
						return .none

					case .didOpenSettings:
						state.sheet.transition(to: .settings)
						return .none

					case .didOpenGamePicker:
						state.sheet.transition(to: .gamePicker)
						return .none
					}

				case let .gamesSettings(.delegate(delegateAction)):
					switch delegateAction {
					case .didFinish:
						state.sheet.hide(.settings)
						return .none
					}

				case let .gameDetails(.delegate(delegateAction)):
					switch delegateAction {
					case .never:
						return .none
					}

				case let .gameDetailsHeader(.delegate(delegateAction)):
					switch delegateAction {
					case .didProceedToNextElement:
						// TODO: next ball or bowler
						return .none
					}

				case .gameDetails(.internal), .gameDetails(.view):
					return .none

				case .gameDetailsHeader(.internal), .gameDetailsHeader(.view):
					return .none

				case .scoreSheet(.view), .scoreSheet(.internal):
					return .none

				case .rollEditor(.view), .rollEditor(.internal):
					return .none

				case .frameEditor(.view), .frameEditor(.internal):
					return .none

				case .gamePicker(.view), .gamePicker(.internal):
					return .none

				case .ballPicker(.view), .ballPicker(.internal):
					return .none

				case .gamesHeader(.view), .gamesHeader(.internal):
					return .none

				case .gamesSettings(.view), .gamesSettings(.internal):
					return .none
				}

			case .delegate:
				return .none
			}
		}
		.ifLet(\.gameDetails, action: /Action.internal..Action.InternalAction.gameDetails) {
			GameDetails()
		}.ifLet(\.gameDetailsHeader, action: /Action.internal..Action.InternalAction.gameDetailsHeader) {
			GameDetailsHeader()
		}
		.ifLet(\.gamesSettings, action: /Action.internal..Action.InternalAction.gamesSettings) {
			GamesSettings()
		}
		.ifLet(\.frameEditor, action: /Action.internal..Action.InternalAction.frameEditor) {
			FrameEditor()
		}
		.ifLet(\.rollEditor, action: /Action.internal..Action.InternalAction.rollEditor) {
			RollEditor()
		}
		.ifLet(\.scoreSheet, action: /Action.internal..Action.InternalAction.scoreSheet) {
			ScoreSheet()
		}
	}

	private func loadGameDetails(for gameId: Game.ID) -> Effect<Action> {
		return .merge(
			.task {
				await .internal(.framesResponse(TaskResult {
					try await frames.frames(forGame: gameId) ?? []
				}))
			},
			.task {
				await .internal(.gameReponse(TaskResult {
					try await games.edit(gameId)
				}))
			}
		)
		.cancellable(id: CancelObservationID.self, cancelInFlight: true)
	}

	private func updateScoreSheet(from state: State) -> Effect<GamesEditor.Action> {
		guard let frames = state.frames else { return .none }
		return .task {
			let steps = await scoringService.calculateScoreWithSteps(for: frames.map { $0.rolls })
			return .internal(.calculatedScore(steps))
		}
	}
}

// MARK: - GamesHeader

extension GamesEditor.State {
	var gamesHeader: GamesHeader.State {
		get {
			let currentGames = bowlerGames[currentBowlerId]
			return .init(
				numberOfGames: currentGames?.count ?? 0,
				currentGameOrdinal: currentGames?.firstIndex(of: currentGameId) ?? 0
			)
		}
		set {}
	}
}

// MARK: - GamePicker

extension GamesEditor.State {
	var gamePicker: GamePicker.State {
		get { .init(games: bowlerGames[currentBowlerId] ?? [], selected: currentGameId) }
		set { self.currentGameId = newValue.selected }
	}
}

// MARK: - GamesSettings

extension GamesEditor.State {
	var gamesSettings: GamesSettings.State? {
		get {
			guard let currentGame else { return nil }
			return .init(game: currentGame)
		}
		set {
			guard let newValue, currentGameId == newValue.game.id else { return }
			currentGame = newValue.game
		}
	}
}

// MARK: - GameDetailsHeader

extension GamesEditor.State {
	var gameDetailsHeader: GameDetailsHeader.State? {
		get {
			guard let currentGame else { return nil }
			return .init(game: currentGame, nextElement: nil)
		}
		set { }
	}
}

// MARK: - GameDetails

extension GamesEditor.State {
	var gameDetails: GameDetails.State? {
		get {
			guard let currentGame else { return nil }
			return .init(game: currentGame)
		}
		set {
			guard let newValue, currentGameId == newValue.game.id else { return }
			currentGame = newValue.game
		}
	}
}

// MARK: - FrameEditor

extension GamesEditor.State {
	var frameEditor: FrameEditor.State? {
		get {
			guard let _frameEditor, let frames else { return nil }
			var frameEditor = _frameEditor
			frameEditor.currentRollIndex = currentRollIndex
			frameEditor.frame = frames[currentFrameIndex]
			return frameEditor
		}
		set {
			_frameEditor = newValue
			guard let newValue else { return }
			self.currentRollIndex = newValue.currentRollIndex
			self.frames?[self.currentFrameIndex].guaranteeRollExists(upTo: currentRollIndex)
			self.frames?[self.currentFrameIndex] = newValue.frame
		}
	}
}

// MARK: - BallPicker

extension GamesEditor.State {
	var ballPicker: BallPicker.State {
		get {
			var picker = _ballPicker
			picker.forBowler = currentBowlerId
			picker.selected = frames?[currentFrameIndex].rolls[currentRollIndex].bowlingBall?.id
			return picker
		}
		set {
			_ballPicker = newValue
			frames?[currentFrameIndex].setBowlingBall(newValue.selectedBall?.rolled, forRoll: currentRollIndex)
		}
	}
}

// MARK: - RollEditor

extension GamesEditor.State {
	var rollEditor: RollEditor.State? {
		get {
			guard let _rollEditor, let frames else { return nil }
			var rollEditor = _rollEditor
			let currentRoll = frames[currentFrameIndex].rolls[currentRollIndex]
			rollEditor.ballRolled = currentRoll.bowlingBall
			rollEditor.didFoul = currentRoll.roll.didFoul
			return rollEditor
		}
		set {
			_rollEditor = newValue
			guard let newValue else { return }
			frames?[currentFrameIndex].setDidFoul(newValue.didFoul, forRoll: currentRollIndex)
		}
	}
}

// MARK: - Scoresheet

extension GamesEditor.State {
	var scoreSheet: ScoreSheet.State? {
		get {
			guard let scoreSteps else { return nil }
			return .init(
				steps: scoreSteps,
				currentFrameIndex: currentFrameIndex,
				currentRollIndex: currentRollIndex
			)
		}
		set {
			guard let newValue else { return }
			currentRollIndex = newValue.currentRollIndex
			currentFrameIndex = newValue.currentFrameIndex
			frames?[currentFrameIndex].guaranteeRollExists(upTo: currentRollIndex)
		}
	}
}

// MARK: - Sheet

extension GamesEditor.State {
	public enum Sheet: Equatable {
		case gamePicker
		case gameDetails
		case ballPicker
		case settings

		static let `default`: Self = .gameDetails
	}

	public enum SheetState: Equatable {
		case presenting(Sheet)
		case transitioning(to: Sheet)

		mutating func handle(isPresented: Bool, for sheet: Sheet) {
			switch self {
			case .presenting:
				if isPresented {
					self.transition(to: sheet)
				} else {
					self.transition(to: .default)
				}
			case .transitioning:
				break
			}
		}

		mutating func transition(to: Sheet) {
			switch self {
			case .presenting(to):
				break
			case .presenting, .transitioning:
				self = .transitioning(to: to)
			}
		}

		mutating func hide(_ sheet: Sheet) {
			switch self {
			case .presenting(sheet), .transitioning(to: sheet):
				self.transition(to: .default)
			case .presenting, .transitioning:
				break
			}
		}

		mutating func finishTransition() {
			switch self {
			case let .transitioning(to):
				self = .presenting(to)
			case .presenting:
				break
			}
		}
	}
}
