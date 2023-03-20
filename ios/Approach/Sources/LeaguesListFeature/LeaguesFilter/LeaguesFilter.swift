import ComposableArchitecture
import FeatureActionLibrary
import LeaguesDataProviderInterface
import SharedModelsFetchableLibrary
import SharedModelsLibrary

public struct LeaguesFilter: Reducer {
	public struct State: Equatable {
		@BindingState public var recurrence: League.Recurrence?

		public init() {}
	}

	public enum Action: FeatureAction, BindableAction, Equatable {
		public enum ViewAction: Equatable {
			case didTapClearButton
			case didTapApplyButton
		}
		public enum DelegateAction: Equatable {
			case didChangeFilters
			case didApplyFilters
		}
		public enum InternalAction: Equatable {}

		case binding(BindingAction<State>)
		case view(ViewAction)
		case `internal`(InternalAction)
		case delegate(DelegateAction)
	}

	public init() {}

	public var body: some Reducer<State, Action> {
		BindingReducer()

		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case .didTapClearButton:
					state = .init()
					return .task { .delegate(.didApplyFilters) }

				case .didTapApplyButton:
					return .task { .delegate(.didApplyFilters) }
				}

			case .binding:
				return .task { .delegate(.didChangeFilters) }

			case let .internal(internalAction):
				switch internalAction {
				case .never:
					return .none
				}

			case .delegate:
				return .none
			}
		}
	}
}

extension LeaguesFilter.State {
	public var hasFilters: Bool {
		recurrence != nil
	}

	public func filter(withBowler: Bowler) -> League.FetchRequest.Filter {
		.properties(bowler: withBowler, recurrence: recurrence)
	}
}
