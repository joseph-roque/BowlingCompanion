import AlleyEditorFeature
import AssetsLibrary
import ComposableArchitecture
import ErrorsFeature
import ExtensionsLibrary
import FeatureActionLibrary
import ModelsLibrary
import ModelsViewsLibrary
import ResourceListLibrary
import StringsLibrary
import SwiftUI
import SwiftUIExtensionsLibrary
import ViewsLibrary

@ViewAction(for: AlleysList.self)
public struct AlleysListView: View {
	@Perception.Bindable public var store: StoreOf<AlleysList>

	public init(store: StoreOf<AlleysList>) {
		self.store = store
	}

	public var body: some View {
		WithPerceptionTracking {
			ResourceListView(
				store: store.scope(state: \.list, action: \.internal.list)
			) { alley in
				if store.isShowingAverages {
					VStack {
						Alley.View(alley)
						Text(format(average: alley.average))
							.font(.caption)
					}
				} else {
					Alley.View(alley)
				}
			} header: {
				header
			}
			.navigationTitle(Strings.Alley.List.title)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					FilterButton(isActive: store.isAnyFilterActive) {
						send(.didTapFiltersButton)
					}
				}
			}
			// TODO: enable errors
//			.errors(store: store.scope(state: \.errors, action: \.internal.errors))
			.alleyEditor($store.scope(state: \.destination?.editor, action: \.internal.destination.editor))
			.alleysFilter($store.scope(state: \.destination?.filters, action: \.internal.destination.filters))
		}
	}

	@ViewBuilder private var header: some View {
		if store.isShowingAverages {
			Section {
				Button { send(.didTapBowler) } label: {
					LabeledContent(
						Strings.List.Averages.showAverages,
						value: store.bowlerName ?? Strings.List.Averages.allBowlers
					)
				}
				.buttonStyle(.navigation)
			}
		} else {
			EmptyView()
		}
	}
}

@MainActor extension View {
	fileprivate func alleyEditor(_ store: Binding<StoreOf<AlleyEditor>?>) -> some View {
		sheet(item: store) { store in
			NavigationStack {
				AlleyEditorView(store: store)
			}
		}
	}

	fileprivate func alleysFilter(_ store: Binding<StoreOf<AlleysFilter>?>) -> some View {
		sheet(item: store) { store in
			NavigationStack {
				AlleysFilterView(store: store)
			}
			.presentationDetents([.medium, .large])
		}
	}
}
