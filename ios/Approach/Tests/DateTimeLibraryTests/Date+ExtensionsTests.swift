import DateTimeLibrary
import XCTest

final class DateExtensionTests: XCTestCase {
	func testLongDateFormat() {
		let date = Date(timeIntervalSince1970: 72_072)
		XCTAssertEqual(date.longFormat, "January 1, 1970")
	}

	func testShortDateFormat() {
		let date = Date(timeIntervalSince1970: 72_072)
		XCTAssertEqual(date.shortFormat, "Thu, Jan 1")
	}
}
