import XCTest
@testable import Syntax

private let testString: StaticString =
"""
# Here's to the crazy ones.

The misfits. The bla bla.
I needed a test string.

## Another header (2)

> quote - missing author
"""

//private enum CharacterToken: Character, CaseIterable, Syntax.CharacterToken {
//    @available(OSX 10.15.0, *)
//    static var descriptor: some TokenDescriptor {
//        allCases.map { CharacterTokenDescriptor(token: $0.rawValue, type: CharacterToken.self) }
//    }
//}

private struct HeaderToken: RawRepresentable, Token {

    let rawValue: Substring

    init(rawValue: Substring) {
        self.rawValue = rawValue
    }
}

private struct HeaderTokenDescriptor: TokenDescriptor {

    func first(in container: Tokenizer.Container) throws -> Analysis<Token>? {
        guard container.remainder.first == "#" else { return nil } // Early escape if there is no hash
        guard container.offset <= container.base.startIndex else { return nil } // First char in the file
        guard container.base[container.base.index(before: container.offset)] == "\n" else { // First after new line
            return nil
        }

        // Now advance on each hash
        var offset = container.offset
        while offset < container.base.endIndex, container.remainder[offset] == "#" {
            offset = container.base.index(after: offset)
        }

        // Return nil result (i.e. no token) if there are more than 6 hashes at once otherwise the scanned substring
        let token = container.base[container.offset...offset]
        return token.count <= 6 ? (result: HeaderToken(rawValue: token), numberOfElementsConsumed: token.count) : nil
    }
}

final class TokenizerTests: XCTestCase {

    func testExample() {

        let headerTokenizer: HeaderTokenDescriptor = .init()

        let tokenizer = Tokenizer(descriptor: [headerTokenizer], configuration: .init(ignoredCharacters: []))

        let analysee = testString
        XCTAssertNoThrow(try tokenizer.analyse(data: analysee.data(using: .utf8)!, encoding: .utf8))

        var tokens: [Token] = []
        XCTAssertNoThrow(tokens = try tokenizer.analyse(string: analysee))
        XCTAssertTrue(tokens.count == 9)

        XCTAssertTrue((tokens[0] as? CharacterToken) == .parentheseOpen)
        XCTAssertTrue((tokens[1] as? CharacterToken) == .bracketOpen)
        if let token = tokens[2] as? Keyword {
            XCTAssertTrue(token == .unless)
        } else {
            XCTFail()
        }
        XCTAssertTrue((tokens[3] as? CharacterToken) == .bracketClose)
        XCTAssertTrue((tokens[4] as? CharacterToken) == .bracketOpen)
        if let token = tokens[5] as? Variable {
            XCTAssertTrue(token.name == "asd")
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

//@available(OSX 10.15.0, *)
//class ParserTests: XCTestCase {
//
//    func testExample() {
//
//        let characterDescriptor = CharacterToken.descriptor
//        let tokenizer = Tokenizer(descriptors: [characterDescriptor])
//
//
//        var tokenDescriptors: [TokenDescriptor] = CharacterToken.allCases.map {
//            CharacterTokenDescriptor(token: $0.rawValue, type: CharacterToken.self)
//        }
//        tokenDescriptors.append(contentsOf: Keyword.allCases.map {
//            try! KeywordTokenDescriptor(token: $0.rawValue, type: Keyword.self)
//        })
//
//        let variableExpression = try! NSRegularExpression(pattern: "^[a-zA-Z_$][a-zA-Z_$0-9]*", options: [])
//        tokenDescriptors.append(PatternTokenDescriptor(regularExpression: variableExpression, type: Variable.self))
//        tokenDescriptors.append(StringTokenDescriptor())
//
//        let analysee = "unless asd_fgh,fgh_JKL,_J123823"
//        let tokenizer = Tokenizer(descriptors: tokenDescriptors)
//        let tokens = try! tokenizer.analyse(string: analysee)
//
//        var nodeDescriptor: [NodeDescriptor] = []
//        nodeDescriptor.append(CollectionDescriptor())
//        nodeDescriptor.append(KeywordDescriptor())
//        nodeDescriptor.append(PatternDescriptor())
//        let parser = Parser(descriptors: nodeDescriptor)
//
//        var syntaxTree: Node!
//        XCTAssertNoThrow(syntaxTree = try parser.analyse(container: tokens))
//
//        XCTAssertNotNil(syntaxTree as? [Node])
//        let nodes = syntaxTree as! [Node]
//        XCTAssert(nodes[0] as? Keyword == .unless)
//        XCTAssertNotNil(nodes[1] as? [Node])
//        let collection = nodes[1] as! [Node]
//        XCTAssert((collection[0] as? Variable)?.name == "asd_fgh")
//        XCTAssert((collection[1] as? Variable)?.name == "fgh_JKL")
//        XCTAssert((collection[2] as? Variable)?.name == "_J123823")
//        XCTAssert(collection.count == 3)
//    }
//
//    static var allTests = [
//        ("testExample", testExample),
//    ]
//}
//
//import XCTest
//@testable import Syntax
//
//final class TokenizerTests: XCTestCase {
//
//    func testExample() {
//
//        var descriptors: [TokenDescriptor] = CharacterToken.allCases.map {
//            CharacterTokenDescriptor(token: $0.rawValue, type: CharacterToken.self)
//        }
//        descriptors.append(contentsOf: Keyword.allCases.map {
//            try! KeywordTokenDescriptor(token: $0.rawValue, type: Keyword.self)
//        })
//
//        let variableExpression = try! NSRegularExpression(pattern: "^[a-zA-Z_$][a-zA-Z_$0-9]*", options: [])
//        descriptors.append(PatternTokenDescriptor(regularExpression: variableExpression, type: Variable.self))
//        descriptors.append(StringTokenDescriptor())
//
//        let tokenizer = Tokenizer(descriptors: descriptors)
//
//        let analysee = "([unless] [asd] \"some string\")"
//        XCTAssertNoThrow(try tokenizer.analyse(data: analysee.data(using: .utf8)!, encoding: .utf8))
//
//        var tokens: [Token] = []
//        XCTAssertNoThrow(tokens = try tokenizer.analyse(string: analysee))
//        XCTAssertTrue(tokens.count == 9)
//
//        XCTAssertTrue((tokens[0] as? CharacterToken) == .parentheseOpen)
//        XCTAssertTrue((tokens[1] as? CharacterToken) == .bracketOpen)
//        if let token = tokens[2] as? Keyword {
//            XCTAssertTrue(token == .unless)
//        } else {
//            XCTFail()
//        }
//        XCTAssertTrue((tokens[3] as? CharacterToken) == .bracketClose)
//        XCTAssertTrue((tokens[4] as? CharacterToken) == .bracketOpen)
//        if let token = tokens[5] as? Variable {
//            XCTAssertTrue(token.name == "asd")
//        } else {
//            XCTFail()
//        }
//        XCTAssertTrue((tokens[6] as? CharacterToken) == .bracketClose)
//        XCTAssertTrue((tokens[7] as? Substring) == "\"some string\"")
//        XCTAssertTrue((tokens[8] as? CharacterToken) == .parentheseClose)
//    }
//
//    static var allTests = [
//        ("testExample", testExample),
//    ]
//}
