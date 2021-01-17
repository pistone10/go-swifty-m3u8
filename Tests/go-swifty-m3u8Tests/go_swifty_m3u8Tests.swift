import XCTest
@testable import go_swifty_m3u8

final class go_swifty_m3u8Tests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(go_swifty_m3u8().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
