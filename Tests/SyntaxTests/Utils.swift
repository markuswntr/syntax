import Syntax
import Foundation

// MARK: "Models"

extension Substring: Token {}
extension String: Node {}
extension Double: Node {}

enum CharacterToken: Character, CaseIterable, Syntax.CharacterToken {
    case parentheseOpen = "("
    case parentheseClose = ")"
    case bracketOpen = "["
    case bracketClose = "]"
    case collectionSeparator = ","
}

enum KeywordToken: String, CaseIterable, Syntax.KeywordToken, Node {
    case unless
    case `switch` // Will properly resolve
}

enum PatternToken: Syntax.PatternToken {
    case variable(Substring)

    init?(value: String.SubSequence) {
        self = .variable(value)
    }
}

// MARK: Descriptions

final class KeywordDescription: NodeDescriptor {

    func first<Container: Collection>(
        in container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {
        guard let keyword = container.first as? KeywordToken else {
            return nil
        } // This will do fine for testing
        return (keyword, consumedToken: 1)
    }
}

final class PatternDescription: NodeDescriptor {

    // MARK: NodeDescription

    func first<Container: Collection>(
        in container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {

        let node: Node
        switch container.first as? PatternToken {
        case let .variable(value)?:
            node = String(value)
//        case let .number(value)?:
//            guard let doubleValue = Double(value) else {
//                throw DecodingError.dataCorrupted(.init(
//                    codingPath: [], debugDescription: "The numeric value \(value) is not double convertible."))
//            }
//            node = doubleValue
        default: return nil
        }
        return (node, consumedToken: 1)
    }
}

final class StringTokenDescription: TokenDescriptor {

    func first(in container: Tokenizer.Container) throws -> (Token, consumedLength: Int)? {
        guard container.remainder.first == "\"" else { return nil }

        var currentOffset = container.remainder.index(after: container.remainder.startIndex) // Current char is a quote, so go to the next
        while currentOffset < container.remainder.endIndex, container.remainder[currentOffset] != "\"" {
            currentOffset = container.remainder.index(after: currentOffset)
        }

        // Perform a validation on both loop terminations. The loop must end on a quote ("), not on the end index.
        guard currentOffset < container.remainder.endIndex && container.remainder[currentOffset] == "\"" else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "Found an unterminated string in \(container.remainder)"))
        }
        // "Manually" advance by one character, as the loop above ends scanning ON the trailing quote (").
        // Advancing the index by one character will include the quote (") accordingly.
        currentOffset = container.remainder.index(after: currentOffset)
        let substring = container.remainder[container.remainder.startIndex..<currentOffset]
        return (substring, substring.count)
    }
}


/// A description for collections defined as: `a,b,c,d`
final class CollectionDescription: NodeDescriptor {

    func first<Container: Collection>(
        in container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {

        // #1 check: There must be at least 3 tokens (node, collection separator, node) left in given container
        guard container.count > 2 else { return nil }

        // #2 check: The first token must not be a collection separator
        var currentIndex = container.startIndex
        guard container[currentIndex] as? CharacterToken != .collectionSeparator else { return nil }

        // #3 check: The second token must be a collection separator
        var nextIndex = container.index(after: currentIndex)
        guard container[nextIndex] as? CharacterToken == .collectionSeparator else { return nil }

        // The nodes in the collection
        var collection: [Node] = []
        while nextIndex < container.endIndex, container[nextIndex] as? CharacterToken == .collectionSeparator {
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
