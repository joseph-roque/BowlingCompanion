import BaseFormLibrary
import ComposableArchitecture
import ExtensionsLibrary
import FeatureActionLibrary
import Foundation
import PersistenceServiceInterface
import SharedModelsLibrary
import StringsLibrary

extension Opponent: BaseFormModel {
	static public var modelName = Strings.Opponent.title
}

public struct OpponentEditor: Reducer {
	public typealias Form = BaseForm<Opponent, Fields>

	public struct Fields: BaseFormState, Equatable {
		@BindingState public var name = ""

		public let isDeleteable = true
		public var isSaveable: Bool {
			!name.isEmpty
		}
	}

	public struct State: Equatable {
		public var base: Form.State

		public init(mode: Form.Mode) {
			var fields = Fields()
			if case let .edit(opponent) = mode {
				fields.name = opponent.name
			}

			self.base = .init(mode: mode, form: fields)
		}
	}

	public enum Action: FeatureAction, BindableAction, Equatable {
		public enum ViewAction: Equatable {}
		public enum DelegateAction: Equatable {
			case didFinishEditing
		}
		public enum InternalAction: Equatable {
			case form(Form.Action)
		}

		case view(ViewAction)
		case delegate(DelegateAction)
		case `internal`(InternalAction)
		case binding(BindingAction<State>)
	}

	public init() {}

	@Dependency(\.uuid) var uuid
	@Dependency(\.persistenceService) var persistenceService

	public var body: some Reducer<State, Action> {
		BindingReducer()

		Scope(state: \.base, action: /Action.internal..Action.InternalAction.form) {
			BaseForm()
				.dependency(\.modelPersistence, .init(
					save: persistenceService.saveOpponent,
					delete: persistenceService.deleteOpponent
				))
		}

		Reduce<State, Action> { _, action in
			switch action {
			case let .internal(internalAction):
				switch internalAction {
				case let .form(.delegate(delegateAction)):
					switch delegateAction {
					case let .didSaveModel(opponent):
						return .task { .internal(.form(.callback(.didFinishSaving(.success(opponent))))) }

					case let .didDeleteModel(opponent):
						return .task { .internal(.form(.callback(.didFinishDeleting(.success(opponent))))) }

					case .didFinishSaving, .didFinishDeleting, .didDiscard:
						return .task { .delegate(.didFinishEditing) }
					}

				case .form(.view), .form(.internal), .form(.callback):
					return .none
				}

			case let .view(viewAction):
				switch viewAction {
				case .never:
					return .none
				}

			case .binding, .delegate:
				return .none
			}
		}
	}
}

extension OpponentEditor.Fields {
	public var model: Opponent {
		.init(id: .placeholder, name: name)
	}
}
