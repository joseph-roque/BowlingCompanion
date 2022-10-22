import ComposableArchitecture
import Foundation
import LeaguesDataProviderInterface
import RegexBuilder
import SharedModelsLibrary

public struct LeagueForm: ReducerProtocol {
	public struct State: Equatable {
		public var bowler: Bowler
		public var mode: Mode
		public var name = ""
		public var recurrence: League.Recurrence = .repeating
		public var numberOfGames = League.DEFAULT_NUMBER_OF_GAMES
		public var additionalPinfall = ""
		public var additionalGames = ""
		public var hasAdditionalPinfall = false
		public var isSaving = false

		public init(bowler: Bowler, mode: Mode) {
			self.bowler = bowler
			self.mode = mode
			if case let .edit(league) = mode {
				self.name = league.name
				self.recurrence = league.recurrence
				self.numberOfGames = league.numberOfGames
				self.additionalGames = "\(league.additionalGames ?? 0)"
				self.additionalPinfall = "\(league.additionalPinfall ?? 0)"
				self.hasAdditionalPinfall = (league.additionalGames ?? 0) > 0
			}
		}
	}

	public enum Mode: Equatable {
		case create
		case edit(League)
	}

	public enum Action: Equatable {
		case nameChange(String)
		case recurrenceChange(League.Recurrence)
		case numberOfGamesChange(Int)
		case additionalPinfallChange(String)
		case additionalGamesChange(String)
		case setHasAdditionalPinfall(enabled: Bool)
		case saveButtonTapped
		case saveLeagueResult(TaskResult<League>)
	}

	public init() {}

	@Dependency(\.uuid) var uuid
	@Dependency(\.date) var date
	@Dependency(\.leaguesDataProvider) var leaguesDataProvider

	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case let .nameChange(name):
				state.name = name
				return .none

			case let .recurrenceChange(recurrence):
				state.recurrence = recurrence
				return .none

			case let .numberOfGamesChange(numberOfGames):
				state.numberOfGames = numberOfGames
				return .none

			case let .additionalGamesChange(additionalGames):
				state.additionalGames = additionalGames.replacing(#/\D+/#, with: "")
				return .none

			case let .additionalPinfallChange(additionalPinfall):
				state.additionalPinfall = additionalPinfall.replacing(#/\D+/#, with: "")
				return .none

			case let .setHasAdditionalPinfall(enabled):
				state.hasAdditionalPinfall = enabled
				return .none

			case .saveButtonTapped:
				state.isSaving = true
				let league = state.league(id: uuid(), createdAt: date(), lastModifiedAt: date())
				return .task {
					return await .saveLeagueResult(TaskResult {
						try await leaguesDataProvider.create(league)
						return league
					})
				}

			case .saveLeagueResult(.success):
				state.isSaving = false
				return .none

			case .saveLeagueResult(.failure):
				// TODO: show error to user for failed save to db
				state.isSaving = false
				return .none
			}
		}
	}
}

extension LeagueForm.State {
	func league(id: UUID, createdAt: Date, lastModifiedAt: Date) -> League {
		let additionalGames = hasAdditionalPinfall ? Int(additionalGames) : nil
		let additionalPinfall: Int?
		if let additionalGames {
			additionalPinfall = hasAdditionalPinfall && additionalGames > 0 ? Int(self.additionalPinfall) : nil
		} else {
			additionalPinfall = nil
		}
		return .init(
			bowlerId: bowler.id,
			id: id,
			name: name,
			recurrence: recurrence,
			numberOfGames: numberOfGames,
			additionalPinfall: additionalPinfall,
			additionalGames: additionalGames,
			createdAt: createdAt,
			lastModifiedAt: lastModifiedAt
		)
	}
}
