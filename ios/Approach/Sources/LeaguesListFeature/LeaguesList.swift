import ComposableArchitecture
import FeatureActionLibrary
import LeagueEditorFeature
import LeaguesRepositoryInterface
import ModelsLibrary
import RecentlyUsedServiceInterface
import ResourceListLibrary
import SeriesListFeature
import SortOrderLibrary
import StringsLibrary
import ViewsLibrary

extension League.Summary: ResourceListItem {}

extension League.Ordering: CustomStringConvertible {
	public var description: String {
		switch self {
		case .byRecentlyUsed: return Strings.Ordering.mostRecentlyUsed
		case .byName: return Strings.Ordering.alphabetical
		}
	}
}

public struct LeaguesList: Reducer {
	public struct State: Equatable {
		public let bowler: Bowler.Summary

		public var list: ResourceList<League.Summary, League.Summary.FetchRequest>.State
		public var editor: LeagueEditor.State?
		public var sortOrder: SortOrder<League.Ordering>.State = .init(initialValue: .byRecentlyUsed)

		public var isFiltersPresented = false
		public var filters: LeaguesFilter.State = .init()

		public var selection: Identified<League.ID, SeriesList.State>?

		public init(bowler: Bowler.Summary) {
			self.bowler = bowler
			self.list = .init(
				features: [
					.add,
					.swipeToEdit,
					.swipeToDelete(onDelete: .init {
						@Dependency(\.leagues) var leagues: LeaguesRepository
						try await leagues.delete($0.id)
					}),
				],
				query: .init(
					filter: filters.filter(withBowler: bowler),
					ordering: sortOrder.ordering
				),
				listTitle: Strings.League.List.title,
				emptyContent: .init(
					image: .emptyLeagues,
					title: Strings.League.Error.Empty.title,
					message: Strings.League.Error.Empty.message,
					action: Strings.League.List.add
				)
			)
		}
	}

	public enum Action: FeatureAction, Equatable {
		public enum ViewAction: Equatable {
			case setNavigation(selection: League.ID?)
			case setFilterSheet(isPresented: Bool)
			case setEditorSheet(isPresented: Bool)
		}

		public enum DelegateAction: Equatable {}

		public enum InternalAction: Equatable {
			case didLoadEditableLeague(League.Editable)
			case didLoadSeriesLeague(League.SeriesHost)
			case list(ResourceList<League.Summary, League.Summary.FetchRequest>.Action)
			case editor(LeagueEditor.Action)
			case filters(LeaguesFilter.Action)
			case series(SeriesList.Action)
			case sortOrder(SortOrder<League.Ordering>.Action)
		}

		case view(ViewAction)
		case `internal`(InternalAction)
		case delegate(DelegateAction)
	}

	public init() {}

	@Dependency(\.continuousClock) var clock
	@Dependency(\.leagues) var leagues
	@Dependency(\.recentlyUsedService) var recentlyUsedService
	@Dependency(\.featureFlags) var featureFlags

	public var body: some Reducer<State, Action> {
		Scope(state: \.sortOrder, action: /Action.internal..Action.InternalAction.sortOrder) {
			SortOrder()
		}

		Scope(state: \.filters, action: /Action.internal..Action.InternalAction.filters) {
			LeaguesFilter()
		}

		Scope(state: \.list, action: /Action.internal..Action.InternalAction.list) {
			ResourceList { request in
				leagues.list(
					bowledBy: request.filter.bowler,
					withRecurrence: request.filter.recurrence,
					ordering: request.ordering
				)
			}
		}

		Reduce<State, Action> { state, action in
			switch action {
			case let .view(viewAction):
				switch viewAction {
				case let .setNavigation(selection: .some(id)):
					return .run { send in
						guard let league = try await leagues.seriesHost(id) else {
							// TODO: report league not found
							return
						}

						await send(.internal(.didLoadSeriesLeague(league)))
					}

				case .setNavigation(selection: .none):
					return navigate(to: nil, state: &state)

				case let .setFilterSheet(isPresented):
					state.isFiltersPresented = isPresented
					return .none

				case .setEditorSheet(isPresented: true):
					return startEditing(league: nil, state: &state)

				case .setEditorSheet(isPresented: false):
					state.editor = nil
					return .none
				}

			case let .internal(internalAction):
				switch internalAction {
				case let .didLoadEditableLeague(league):
					return startEditing(league: league, state: &state)

				case let .didLoadSeriesLeague(league):
					return navigate(to: league, state: &state)

				case let .list(.delegate(delegateAction)):
					switch delegateAction {
					case let .didEdit(league):
						return .run { send in
							guard let editable = try await leagues.edit(league.id) else {
								// TODO: report league not found
								return
							}

							await send(.internal(.didLoadEditableLeague(editable)))
						}

					case .didAddNew, .didTapEmptyStateButton:
						return startEditing(league: nil, state: &state)

					case .didDelete, .didTap:
						return .none
					}

				case let .sortOrder(.delegate(delegateAction)):
					switch delegateAction {
					case .didTapOption:
						return state.list.updateQuery(
							to: .init(filter: state.filters.filter(withBowler: state.bowler), ordering: state.sortOrder.ordering)
						).map { .internal(.list($0)) }
					}

				case let .filters(.delegate(delegateAction)):
					switch delegateAction {
					case .didApplyFilters:
						state.isFiltersPresented = false
						return .none

					case .didChangeFilters:
						return state.list.updateQuery(
							to: .init(filter: state.filters.filter(withBowler: state.bowler), ordering: state.sortOrder.ordering)
						).map { .internal(.list($0)) }
					}

				case let .editor(.delegate(delegateAction)):
					switch delegateAction {
					case .didFinishEditing:
						state.editor = nil
						return .none
					}

				case let .series(.delegate(delegateAction)):
					switch delegateAction {
					case .never:
						return .none
					}

				case .editor(.internal), .editor(.view), .editor(.binding):
					return .none

				case .list(.internal), .list(.view):
					return .none

				case .filters(.internal), .filters(.view), .filters(.binding):
					return .none

				case .series(.internal), .series(.view):
					return .none

				case .sortOrder(.internal), .sortOrder(.view):
					return .none
				}

			case .delegate:
				return .none
			}
		}
		.ifLet(\.editor, action: /Action.internal..Action.InternalAction.editor) {
			LeagueEditor()
		}
		.ifLet(\.selection, action: /Action.internal..Action.InternalAction.series) {
			Scope(state: \Identified<League.ID, SeriesList.State>.value, action: /.self) {
				SeriesList()
			}
		}
	}

	private func navigate(to league: League.SeriesHost?, state: inout State) -> Effect<Action> {
		if let league {
			state.selection = Identified(.init(league: league), id: league.id)
			return .fireAndForget {
				try await clock.sleep(for: .seconds(1))
				recentlyUsedService.didRecentlyUseResource(.leagues, league.id)
			}
		} else {
			state.selection = nil
			return .none
		}
	}

	private func startEditing(league: League.Editable?, state: inout State) -> Effect<Action> {
		let mode: LeagueEditor.Form.Mode
		if let league {
			mode = .edit(league)
		} else {
			mode = .create
		}

		state.editor = .init(
			bowler: state.bowler.id,
			mode: mode,
			hasAlleysEnabled: featureFlags.isEnabled(.alleys)
		)

		return .none
	}
}
