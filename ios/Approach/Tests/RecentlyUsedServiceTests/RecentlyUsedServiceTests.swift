import Dependencies
import PreferenceServiceInterface
@testable import RecentlyUsedService
import RecentlyUsedServiceInterface
import XCTest

final class RecentlyUsedServiceTests: XCTestCase {
	@Dependency(\.recentlyUsed) var recentlyUsed

	func testUpdatesRecentlyUsedResource() {
		let id0 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
		let now = Date(timeIntervalSince1970: 1672519204)

		let expectation = self.expectation(description: "updated recently used")

		withDependencies {
			$0.recentlyUsed = .liveValue
			$0.date = .constant(now)

			$0.preferences.getString = { key in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				return nil
			}

			$0.preferences.setString = { key, value in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				XCTAssertEqual(Self.entriesString(ids: [id0]), value)
				expectation.fulfill()
			}

		} operation: {
			self.recentlyUsed.didRecentlyUseResource(.bowlers, id0)
		}

		waitForExpectations(timeout: 1)
	}

	func testReplacesRecentlyUsedResourceIfExists() {
		let id0 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
		let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
		let now = Date(timeIntervalSince1970: 1672519204)

		let expectation = self.expectation(description: "updated recently used")

		withDependencies {
			$0.recentlyUsed = .liveValue
			$0.date = .constant(now)

			$0.preferences.getString = { key in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				return Self.entriesString(ids: [id0, id1])
			}

			$0.preferences.setString = { key, value in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				XCTAssertEqual(Self.entriesString(ids: [id1, id0]), value)
				expectation.fulfill()
			}
		} operation: {
			self.recentlyUsed.didRecentlyUseResource(.bowlers, id1)
		}

		waitForExpectations(timeout: 1)
	}

	func testResetsResource() {
		let expectation = self.expectation(description: "reset recently used")

		withDependencies {
			$0.recentlyUsed = .liveValue
			$0.preferences.remove = { key in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				expectation.fulfill()
			}
		} operation: {
			self.recentlyUsed.resetRecentlyUsed(.bowlers)
		}

		waitForExpectations(timeout: 1)
	}

	func testObservesChanges() async {
		let id0 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
		let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
		let now = Date(timeIntervalSince1970: 1672519204)

		let getExpectation = self.expectation(description: "got recently used")
		getExpectation.expectedFulfillmentCount = 3
		let updateExpectation = self.expectation(description: "updated recently used")

		await withDependencies {
			$0.recentlyUsed = .liveValue
			$0.preferences.getString = { key in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				getExpectation.fulfill()
				return Self.entriesString(ids: [id0])
			}

			$0.preferences.setString = { key, value in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				XCTAssertEqual(Self.entriesString(ids: [id1, id0]), value)
				updateExpectation.fulfill()
			}

			$0.date = .constant(now)
		} operation: {
			let recentlyUsed = self.recentlyUsed.observeRecentlyUsed(.bowlers)
			var recentlyUsedIterator = recentlyUsed.makeAsyncIterator()

			let firstValue = await recentlyUsedIterator.next()
			XCTAssertEqual([RecentlyUsedService.Entry(id: id0, lastUsedAt: now)], firstValue)

			self.recentlyUsed.didRecentlyUseResource(.bowlers, id1)

			let secondValue = await recentlyUsedIterator.next()
			XCTAssertEqual([RecentlyUsedService.Entry(id: id0, lastUsedAt: now)], secondValue)
		}

		await fulfillment(of: [getExpectation, updateExpectation])
	}

	func testDoesNotObserveUnrelatedChanges() async {
		let id0 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
		let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
		let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
		let now = Date(timeIntervalSince1970: 1672519204)

		var recentlyUsed: AsyncStream<[RecentlyUsedService.Entry]>?
		var recentlyUsedIterator: AsyncStream<[RecentlyUsedService.Entry]>.Iterator?

		await withDependencies {
			$0.recentlyUsed = .liveValue
			$0.preferences.getString = { key in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				return Self.entriesString(ids: [id0])
			}
		} operation: {
			recentlyUsed = self.recentlyUsed.observeRecentlyUsed(.bowlers)
			recentlyUsedIterator = recentlyUsed!.makeAsyncIterator()

			let firstValue = await recentlyUsedIterator!.next()
			XCTAssertEqual([RecentlyUsedService.Entry(id: id0, lastUsedAt: now)], firstValue)
		}

		withDependencies {
			$0.recentlyUsed = .liveValue
			$0.date = .constant(now)

			$0.preferences.getString = { key in
				XCTAssertEqual("RecentlyUsed.alleys", key)
				return Self.entriesString(ids: [id1])
			}

			$0.preferences.setString = { key, value in
				XCTAssertEqual("RecentlyUsed.alleys", key)
				XCTAssertEqual(Self.entriesString(ids: [id1]), value)
			}
		} operation: {
			self.recentlyUsed.didRecentlyUseResource(.alleys, id1)
		}

		await withDependencies {
			$0.recentlyUsed = .liveValue
			$0.date = .constant(now)

			$0.preferences.getString = { key in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				return Self.entriesString(ids: [id2])
			}

			$0.preferences.setString = { key, value in
				XCTAssertEqual("RecentlyUsed.bowlers", key)
				XCTAssertEqual(Self.entriesString(ids: [id2]), value)
			}
		} operation: {
			self.recentlyUsed.didRecentlyUseResource(.bowlers, id2)

			// We shouldn't see id1 ever surfaced here
			let secondValue = await recentlyUsedIterator!.next()
			XCTAssertEqual([RecentlyUsedService.Entry(id: id2, lastUsedAt: now)], secondValue)
		}
	}

	static func entriesString(ids: [UUID], date: Date = Date(timeIntervalSince1970: 1672519204)) -> String {
		guard let entries = try? JSONEncoder().encode(ids.map { RecentlyUsedService.Entry(id: $0, lastUsedAt: date) }) else {
			XCTFail("Failed to encode entries")
			return ""
		}

		return String(data: entries, encoding: .utf8)!
	}
}