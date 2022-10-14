import BowlersDataProviderInterface
import ComposableArchitecture
import SharedModelsLibrary

public struct BowlerForm: ReducerProtocol {
	public struct State: Equatable, Sendable {
		public var mode: Mode
		public var name = ""
		public var isSaving = false

		public init(mode: Mode) {
			self.mode = mode
			switch mode {
			case .create:
				self.name = ""
			case .edit(let bowler):
				self.name = bowler.name
			}
		}
	}

	public enum Mode: Equatable, Sendable {
		case edit(Bowler)
		case create
	}

	public enum Action: Equatable, Sendable {
		case nameChange(String)
		case saveButtonTapped
		case saveBowlerResult(TaskResult<Bowler>)
	}

	public init() {}

	@Dependency(\.uuid) var uuid
	@Dependency(\.bowlersDataProvider) var bowlersDataProvider

	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case let .nameChange(name):
				state.name = name
				return .none

			case .saveButtonTapped:
				state.isSaving = true
				return .task { [name = state.name] in
					let bowler = Bowler(id: uuid(), name: name)
					return await .saveBowlerResult(TaskResult {
						try await bowlersDataProvider.save(bowler)
						return bowler
					})
				}

			case .saveBowlerResult(.success):
				state.isSaving = false
				return .none

			case .saveBowlerResult(.failure):
				state.isSaving = false
				return .none
			}
		}
	}
}
