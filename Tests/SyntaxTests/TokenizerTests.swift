import XCTest
@testable import Syntax

final class TokenizerTests: XCTestCase {

    func testExample() {

        var descriptors: [TokenDescriptor] = CharacterToken.allCases.map {
            CharacterTokenDescriptor(token: $0.rawValue, type: CharacterToken.self)
        }
        descriptors.append(contentsOf: KeywordToken.allCases.map {
            try! KeywordTokenDescriptor(token: $0.rawValue, type: KeywordToken.self)
        })

        let variableExpression = try! NSRegularExpression(pattern: "^[a-zA-Z_$][a-zA-Z_$0-9]*", options: [])
        descriptors.append(PatternTokenDescriptor(regularExpression: variableExpression, type: PatternToken.self))
        descriptors.append(StringTokenDescription())

        let tokenizer = Tokenizer(descriptors: descriptors)

        let analysee = "([unless] [asd] \"some string\")"
        XCTAssertNoThrow(try tokenizer.analyse(data: analysee.data(using: .utf8)!, encoding: .utf8))

        var tokens: [Token] = []
        XCTAssertNoThrow(tokens = try tokenizer.analyse(string: analysee))
        XCTAssertTrue(tokens.count == 9)
        
        XCTAssertTrue((tokens[0] as? CharacterToken) == .parentheseOpen)
        XCTAssertTrue((tokens[1] as? CharacterToken) == .bracketOpen)
        if let token = tokens[2] as? KeywordToken {
            XCTAssertTrue(token == .unless)
        } else {
            XCTFail()
        }
        XCTAssertTrue((tokens[3] as? CharacterToken) == .bracketClose)
        XCTAssertTrue((tokens[4] as? CharacterToken) == .bracketOpen)
        if let token = tokens[5] as? PatternToken, case let .variable(value) = token {
            XCTAssertTrue(value == "asd")
        } else {
            XCTFail()
        }
        XCTAssertTrue((tokens[6] as? CharacterToken) == .bracketClose)
        XCTAssertTrue((tokens[7] as? Substring) == "\"some string\"")
        XCTAssertTrue((tokens[8] as? CharacterToken) == .parentheseClose)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
