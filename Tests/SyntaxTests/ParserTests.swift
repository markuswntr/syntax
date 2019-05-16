import XCTest
@testable import Syntax

class ParserTests: XCTestCase {

    func testExample() {

        var tokenDescriptions: [TokenDescription] = []
        tokenDescriptions.append(contentsOf: CharacterToken.allCases)
        tokenDescriptions.append(CharacterSetDescription())
        let tokenizer = Tokenizer(descriptions: tokenDescriptions)
        let tokens = try! tokenizer.analyse(string: "keyword instance,123,notanumber")

        let nodeDescriptor = NodeDescriptor()
        nodeDescriptor.append(CollectionDescription())
        nodeDescriptor.append(CharacterSetDescription())
        let parser = Parser(descriptor: nodeDescriptor)

        XCTAssertNoThrow(try parser.analyse(container: tokens))
        let syntaxTree = try! parser.analyse(container: tokens)

        XCTAssertNotNil(syntaxTree as? [Node])
        let nodes = syntaxTree as! [Node]
        XCTAssert(nodes[0] as? String == "keyword")
        XCTAssertNotNil(nodes[1] as? [Node])
        let collection = nodes[1] as! [Node]
        XCTAssert(collection[0] as? String == "instance")
        XCTAssert(collection[1] as? Double == 123.0)
        XCTAssert(collection[2] as? String == "notanumber")
        XCTAssert(collection.count == 3)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
