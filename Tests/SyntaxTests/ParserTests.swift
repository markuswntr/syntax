import XCTest
@testable import Syntax

class ParserTests: XCTestCase {

    func testExample() {

        var tokenDescriptors: [TokenDescriptor] = CharacterToken.allCases.map {
            CharacterTokenDescriptor(token: $0.rawValue, type: CharacterToken.self)
        }
        tokenDescriptors.append(contentsOf: Keyword.allCases.map {
            try! KeywordTokenDescriptor(token: $0.rawValue, type: Keyword.self)
        })

        let variableExpression = try! NSRegularExpression(pattern: "^[a-zA-Z_$][a-zA-Z_$0-9]*", options: [])
        tokenDescriptors.append(PatternTokenDescriptor(regularExpression: variableExpression, type: Variable.self))
        tokenDescriptors.append(StringTokenDescriptor())

        let analysee = "unless asd_fgh,fgh_JKL,_J123823"
        let tokenizer = Tokenizer(descriptors: tokenDescriptors)
        let tokens = try! tokenizer.analyse(string: analysee)

        var nodeDescriptor: [NodeDescriptor] = []
        nodeDescriptor.append(CollectionDescriptor())
        nodeDescriptor.append(KeywordDescriptor())
        nodeDescriptor.append(PatternDescriptor())
        let parser = Parser(descriptors: nodeDescriptor)

        var syntaxTree: Node!
        XCTAssertNoThrow(syntaxTree = try parser.analyse(container: tokens))

        XCTAssertNotNil(syntaxTree as? [Node])
        let nodes = syntaxTree as! [Node]
        XCTAssert(nodes[0] as? Keyword == .unless)
        XCTAssertNotNil(nodes[1] as? [Node])
        let collection = nodes[1] as! [Node]
        XCTAssert((collection[0] as? Variable)?.name == "asd_fgh")
        XCTAssert((collection[1] as? Variable)?.name == "fgh_JKL")
        XCTAssert((collection[2] as? Variable)?.name == "_J123823")
        XCTAssert(collection.count == 3)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
