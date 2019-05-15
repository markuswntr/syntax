import XCTest
@testable import Syntax

/// A description for collections defined as: `a,b,c,d`
final class CollectionDescription: NodeDescription {

    func node<Container: Collection>(
        for container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {

        // #1 check: There must be at least 3 tokens (node, collection separator, node) left in given container
        guard container.count > 2 else { return nil }

        // #2 check: The first token must not be a collection separator
        var currentIndex = container.startIndex
        guard container[currentIndex] as? CharacterToken != .collectionSeperator else { return nil }

        // #3 check: The second token must be a collection separator
        var nextIndex = container.index(after: currentIndex)
        guard container[nextIndex] as? CharacterToken == .collectionSeperator else { return nil }

        // The nodes in the collection
        var collection: [Node] = []
        while nextIndex < container.endIndex, container[nextIndex] as? CharacterToken == .collectionSeperator {
            // Analyse the node before the next separator and append it to the collection to be generated
            try collection.append(subContainer(container[currentIndex..<nextIndex]))

            // Advance to the token(s) after the separator
            currentIndex = container.index(after: nextIndex)
            guard currentIndex < container.endIndex else {
                // There is no token after the current separator - this is an error
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [], debugDescription: "Found an unterminated collection in \(container)"))
            }
            // Go to the possible the next separator index
            nextIndex = container.index(after: currentIndex)
        }

        // As the loop breaks at the endIndex, the last token needs to be
        // processed separatly if the collection ends the container end
        if nextIndex == container.endIndex {
            try collection.append(subContainer(container[currentIndex..<nextIndex]))
        }

        return (collection, container.distance(from: container.startIndex, to: nextIndex))
    }
}

extension Double: Node {}
extension String: Node {}

final class CharacterSetDescription: NodeDescription {

    func node<Container: Collection>(
        for container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {
        let node: Node
        switch container.first as? CharacterSetToken {
        case let .name(value)?:
            node = String(value)
        case let .number(value)?:
            guard let doubleValue = Double(value) else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [], debugDescription: "The numeric value \(value) is not double convertible."))
            }
            node = doubleValue
        default: return nil
        }
        return (node, consumedToken: 1)
    }
}

class ParserTests: XCTestCase {

    func testExample() {

        let tokenDescriptor = TokenDescriptor()
        tokenDescriptor.append(contentsOf: CharacterToken.allCases)
        tokenDescriptor.append(CharacterSetTokenDescription())
        let tokenizer = Tokenizer(descriptor: tokenDescriptor)
        let tokens = try! tokenizer.analyse(string: "keyword asd,123,xyz")

        let nodeDescriptor = NodeDescriptor()
        nodeDescriptor.append(CollectionDescription())
        nodeDescriptor.append(CharacterSetDescription())
        let parser = Parser(descriptor: nodeDescriptor)

        XCTAssertNoThrow(try parser.analyse(container: tokens))
        let syntaxTree = try! parser.analyse(container: tokens)
        print(syntaxTree)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
