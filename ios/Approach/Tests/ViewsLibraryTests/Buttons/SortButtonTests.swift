import SnapshotTesting
import SwiftUI
import Testing
@testable import ViewsLibrary

struct SortButtonTests {
	@Test("Active sort button snapshot", .tags(.snapshot))
	@MainActor
	func snapshotActiveSortButton() {
		let sortButton = SortButton(isActive: true) { }
		assertSnapshot(of: sortButton, as: .image)
	}

	@Test("Inactive sort button snapshot", .tags(.snapshot))
	@MainActor
	func snapshotInactiveSortButton() {
		let sortButton = SortButton(isActive: false) { }
		assertSnapshot(of: sortButton, as: .image)
	}
}
