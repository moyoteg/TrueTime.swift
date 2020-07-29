import XCTest
@testable import TrueTime

final class TrueTimeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TrueTime().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
