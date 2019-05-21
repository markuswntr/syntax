import XCTest
@testable import Syntax

class ParserTests: XCTestCase {

    func testExample() {

        var tokenDescriptors: [TokenDescriptor] = CharacterToken.allCases.map {
            CharacterTokenDescriptor(token: $0.rawValue, type: CharacterToken.self)
        }
        tokenDescriptors.append(contentsOf: KeywordToken.allCases.map {
            try! KeywordTokenDescriptor(token: $0.rawValue, type: KeywordToken.self)
        })

        let variableExpression = try! NSRegularExpression(pattern: "^[a-zA-Z_$][a-zA-Z_$0-9]*", options: [])
        tokenDescriptors.append(PatternTokenDescriptor(regularExpression: variableExpression, type: PatternToken.self))
        tokenDescriptors.append(StringTokenDescription())

        let analysee = "unless asd_fgh,fgh_JKL,_J123823"
        let tokenizer = Tokenizer(descriptors: tokenDescriptors)
        let tokens = try! tokenizer.analyse(string: analysee)

        let nodeDescriptor = NodeDescriptor()
        nodeDescriptor.append(CollectionDescription())
        nodeDescriptor.append(KeywordDescription())
        nodeDescriptor.append(PatternDescription())
        let parser = Parser(descriptor: nodeDescriptor)

        XCTAssertNoThrow(try parser.analyse(container: tokens))
        let syntaxTree = try! parser.analyse(container: tokens)

        XCTAssertNotNil(syntaxTree as? [Node])
        let nodes = syntaxTree as! [Node]
        XCTAssert(nodes[0] as? KeywordToken == .unless)
        XCTAssertNotNil(nodes[1] as? [Node])
        let collection = nodes[1] as! [Node]
        XCTAssert(collection[0] as? String == "asd_fgh")
        XCTAssert(collection[1] as? String == "fgh_JKL")
        XCTAssert(collection[2] as? String == "_J123823")
        XCTAssert(collection.count == 3)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
