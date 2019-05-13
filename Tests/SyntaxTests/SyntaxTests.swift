import XCTest
@testable import Syntax

final class SyntaxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Syntax().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
