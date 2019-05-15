import XCTest
@testable import Syntax

final class SyntaxTests: XCTestCase {

    func testExample() {

        let descriptor = TokenDescriptor()
        descriptor.append(contentsOf: CharacterToken.allCases)
        descriptor.append(CharacterSetDescription())
        descriptor.append(StringTokenDescription())

        let tokenizer = Tokenizer(descriptor: descriptor)
        XCTAssertNoThrow(try tokenizer.analyse(string: "([123] [asd] \"some string\")"))
        XCTAssertNoThrow(try tokenizer.analyse(
            data: "([123] [asd] \"some string\")".data(using: .utf8)!, encoding: .utf8))
        let tokens = try! tokenizer.analyse(string: "([123] [asd] \"some string\")")

        XCTAssertTrue(tokens.count == 9)
        
        XCTAssertTrue((tokens[0] as? CharacterToken) == .parentheseOpen)
        XCTAssertTrue((tokens[1] as? CharacterToken) == .bracketOpen)
        if let token = tokens[2] as? CharacterSetToken, case let .number(value) = token {
            XCTAssertTrue(value == "123")
        } else {
            XCTFail()
        }
        XCTAssertTrue((tokens[3] as? CharacterToken) == .bracketClose)
        XCTAssertTrue((tokens[4] as? CharacterToken) == .bracketOpen)
        if let token = tokens[5] as? CharacterSetToken, case let .name(value) = token {
            XCTAssertTrue(value == "asd")
        } else {
            XCTFail()
        }
        XCTAssertTrue((tokens[6] as? CharacterToken) == .bracketClose)
        XCTAssertTrue((tokens[7] as? Substring) == Substring("\"some string\""))
        XCTAssertTrue((tokens[8] as? CharacterToken) == .parentheseClose)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
