import AssetsLibrary
import ComposableArchitecture
import FeatureActionLibrary
import SwiftUI

public struct ResourceListEmptyContent: Equatable {
	public let image: UIImage
	public let title: String
	public let message: String?
	public let action: String

	public init(image: UIImage, title: String, message: String? = nil, action: String) {
		self.image = image
		self.title = title
		self.message = message
		self.action = action
	}
}

public struct ResourceListEmpty: ReducerProtocol {
	public struct State: Equatable {
		public var content: ResourceListEmptyContent
		public var style: Style

		public init(
			content: ResourceListEmptyContent,
			style: Style
		) {
			self.content = content
			self.style = style
		}
	}

	public enum Action: Equatable {
		public enum ViewAction: Equatable {}
		public enum InternalAction: Equatable {}
		public enum DelegateAction: Equatable {
			case didTapButton
		}

		case view(ViewAction)
		case `internal`(InternalAction)
		case delegate(DelegateAction)
	}

	public enum Style {
		case empty
		case error
	}

	public init() {}

	public var body: some ReducerProtocol<State, Action> {
		Reduce { _, action in
			switch action {
			case .internal, .delegate, .view:
				return .none
			}
		}
	}
}

public struct ResourceListEmptyView: View {
	let store: StoreOf<ResourceListEmpty>

	struct ViewState: Equatable {
		public let content: ResourceListEmptyContent
		public let style: ResourceListEmpty.Style

		init(state: ResourceListEmpty.State) {
			self.content = state.content
			self.style = state.style
		}
	}

	enum ViewAction {
		case didTapButton
	}

	public init(store: StoreOf<ResourceListEmpty>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store, observe: ViewState.init, send: map(viewAction:)) { viewStore in
			VStack {
				Spacer()

				Image(uiImage: viewStore.content.image)
					.resizable()
					.scaledToFit()
					.padding(.bottom, .smallSpacing)

				Spacer()

				VStack(spacing: .smallSpacing) {
					Text(viewStore.content.title)
						.font(.headline)

					if let message = viewStore.content.message {
						Text(message)
							.multilineTextAlignment(.center)
					}
				}
				.padding()
				.frame(maxWidth: .infinity)
				.background(viewStore.style == .error ? Color.appErrorLight : Color.appPrimaryLight)
				.cornerRadius(.standardRadius)
				.padding(.bottom, .smallSpacing)

				Button {
					viewStore.send(.didTapButton)
				} label: {
					Text(viewStore.content.action)
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)
				.foregroundColor(.white)
				.tint(.appAction)
			}
			.padding()
		}
	}

	private func map(viewAction: ViewAction) -> ResourceListEmpty.Action {
		switch viewAction {
		case .didTapButton:
			return .delegate(.didTapButton)
		}
	}
}
