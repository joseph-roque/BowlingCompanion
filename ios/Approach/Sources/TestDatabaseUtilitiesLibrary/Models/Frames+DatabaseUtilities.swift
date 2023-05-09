import DatabaseModelsLibrary
import Foundation
import GRDB
import ModelsLibrary

func insert(
	frames initial: InitialValue<Frame.Database>?,
	into db: Database
) throws {
	let frames: [Frame.Database]
	switch initial {
	case .none:
		frames = []
	case .default:
		var framesBuilder: [Frame.Database] = []
		for gameIdInt in 0...5 {
			let gameId = UUID(gameIdInt)
			for index in Game.FRAME_INDICES {
				framesBuilder.append(
					.init(
						gameId: gameId,
						index: index,
						roll0: nil,
						roll1: nil,
						roll2: nil,
						ball0: nil,
						ball1: nil,
						ball2: nil
					)
				)
			}
		}
		frames = framesBuilder
	case let .custom(custom):
		frames = custom
	}

	for frame in frames {
		try frame.insert(db)
	}
}
