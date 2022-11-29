import AlleyEditorFeature
import ComposableArchitecture
import SharedModelsLibrary
import StatisticsWidgetsFeature
import StringsLibrary
import SwiftUI
import ThemesLibrary
import ViewsLibrary

public struct AlleysListView: View {
	let store: StoreOf<AlleysList>

	struct ViewState: Equatable {
		let listState: ListContentState<Alley, ListErrorContent>
		let isAlleyEditorPresented: Bool

		init(state: AlleysList.State) {
			if let error = state.error {
				self.listState = .error(error)
			} else if let alleys = state.alleys {
				self.listState = .loaded(alleys)
			} else {
				self.listState = .loading
			}
			self.isAlleyEditorPresented = state.alleyEditor != nil
		}
	}

	enum ViewAction {
		case refreshList
		case addButtonTapped
		case errorButtonTapped
		case setEditorFormSheet(isPresented: Bool)
		case swipeAction(Alley, AlleysList.SwipeAction)
	}

	public init(store: StoreOf<AlleysList>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store, observe: ViewState.init, send: AlleysList.Action.init) { viewStore in
			ListContent(viewStore.listState) { alleys in
				ForEach(alleys) { alley in
					AlleysListRow(viewStore: viewStore, alley: alley)
				}
				.listRowSeparator(.hidden)
			} empty: {
				ListEmptyContent(
					.emptyAlleys,
					title: Strings.Alleys.Errors.Empty.title,
					message: Strings.Alleys.Errors.Empty.message
				) {
					EmptyContentAction(title: Strings.Alleys.List.add) { viewStore.send(.addButtonTapped) }
				}
			} error: { error in
				ListEmptyContent(
					.errorNotFound,
					title: error.title,
					message: error.message,
					style: .error
				) {
					EmptyContentAction(title: error.action) { viewStore.send(.errorButtonTapped) }
				}
			}
			.scrollContentBackground(.hidden)
			.navigationTitle(Strings.Alleys.List.title)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					AddButton { viewStore.send(.addButtonTapped) }
				}
			}
			.sheet(isPresented: viewStore.binding(
				get: \.isAlleyEditorPresented,
				send: ViewAction.setEditorFormSheet(isPresented:)
			)) {
				IfLetStore(store.scope(state: \.alleyEditor, action: AlleysList.Action.alleyEditor)) { scopedStore in
					NavigationView {
						AlleyEditorView(store: scopedStore)
					}
				}
			}
			.alert(
				self.store.scope(state: \.alert, action: AlleysList.Action.alert),
				dismiss: .dismissed
			)
			.onAppear { viewStore.send(.refreshList) }
		}
	}
}

extension AlleysList.Action {
	init(action: AlleysListView.ViewAction) {
		switch action {
		case .refreshList:
			self = .refreshList
		case .addButtonTapped:
			self = .setEditorFormSheet(isPresented: true)
		case .errorButtonTapped:
			self = .errorButtonTapped
		case let .setEditorFormSheet(isPresented):
			self = .setEditorFormSheet(isPresented: isPresented)
		case let .swipeAction(alley, swipeAction):
			self = .swipeAction(alley, swipeAction)
		}
	}
}
