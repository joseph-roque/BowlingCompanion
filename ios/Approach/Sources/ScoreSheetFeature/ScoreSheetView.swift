import ComposableArchitecture
import SharedModelsLibrary
import SwiftUI
import ViewsLibrary

public struct ScoreSheetView: View {
	let store: StoreOf<ScoreSheet>

	struct ViewState: Equatable {
		let frames: [Frame]
		let currentFrameIndex: Int
		let currentRollIndex: Int

		init(state: ScoreSheet.State) {
			self.frames = state.frames
			self.currentFrameIndex = state.currentFrameIndex
			self.currentRollIndex = state.currentRollIndex
		}
	}

	enum ViewAction {
		case didTapFrame(index: Int, rollIndex: Int?)
	}

	public init(store: StoreOf<ScoreSheet>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store, observe: ViewState.init, send: ScoreSheet.Action.init) { viewStore in
			ScrollView(.horizontal) {
				HStack {
					ForEach(viewStore.frames) { frame in
						Button { viewStore.send(.didTapFrame(index: frame.ordinal - 1, rollIndex: nil)) } label: {
							VStack {
								HStack {
									Button { viewStore.send(.didTapFrame(index: frame.ordinal - 1, rollIndex: 0)) } label: {
										Text("5")
									}
								}
							}
						}
						.buttonStyle(TappableElement())
					}
				}
			}
		}
	}
}

extension ScoreSheet.Action {
	init(action: ScoreSheetView.ViewAction) {
		switch action {
		case let .didTapFrame(frameIndex, rollIndex):
			self = .view(.didTapFrame(index: frameIndex, rollIndex: rollIndex))
		}
	}
}
