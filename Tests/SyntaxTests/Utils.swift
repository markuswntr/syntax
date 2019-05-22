import Syntax
import Foundation

// MARK: Models

enum CharacterToken: Character, CaseIterable, Syntax.CharacterToken {
    case parentheseOpen = "("
    case parentheseClose = ")"
    case bracketOpen = "["
    case bracketClose = "]"
    case collectionSeparator = ","
}

enum Keyword: String, CaseIterable, KeywordToken, Node {
    case `switch` // Will properly resolve to "switch"
    case unless
}

struct Variable: PatternToken, Node {
    let name: Substring
    init?(value: String.SubSequence) {
        name = value
    }
}

struct Number: PatternToken, Node {
    let number: Substring
    init?(value: String.SubSequence) {
        number = value
    }
}

// MARK: Descriptions

final class KeywordDescriptor: NodeDescriptor {

    func first<Container: Collection>(
        in container: Container,
        analyse branch: (Container.SubSequence) throws -> Analysis<Node>
    ) throws -> Analysis<Node>? where Container.Element == Token {
        // This descriptor is actually quite useless and missleading. This will do fine for
        // testing but not in real live - dont use or take as template. You have been warned.
        guard let keyword = container.first as? Keyword else { return nil }
        return (result: keyword, numberOfElementsConsumed: 1)
    }
}

final class PatternDescriptor: NodeDescriptor {

    func first<Container: Collection>(
        in container: Container,
        analyse branch: (Container.SubSequence) throws -> Analysis<Node>
    ) throws -> Analysis<Node>? where Container.Element == Token {
        // This descriptor is actually quite useless and missleading. This will do fine for
        // testing but not in real live - dont use or take as template. You have been warned.
        if let variable = container.first as? Variable {
            return (result: variable, numberOfElementsConsumed: 1)
        } else if let number = container.first as? Number {
            return (result: number, numberOfElementsConsumed: 1)
        }
        return nil
    }
}

extension String.SubSequence: Token {}
final class StringTokenDescriptor: TokenDescriptor {

    func first(in container: Tokenizer.Container) throws -> Analysis<Token>? {
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
        return (result: substring, numberOfElementsConsumed: substring.count)
    }
}


/// A description for collections defined as: `a,b,c,d`
extension Array: Node {}
final class CollectionDescriptor: NodeDescriptor {

    func first<Container: Collection>(
        in container: Container,
        analyse branch: (Container.SubSequence) throws -> Analysis<Node>
    ) throws -> Analysis<Node>? where Container.Element == Token {

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
            let (node, _) = try branch(container[currentIndex..<nextIndex])
            collection.append(node)

            // Advance to the token(s) after the separator
            guard currentIndex < container.endIndex else {
                // There is no token after the current separator - this is an error
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [], debugDescription: "Found an unterminated collection in \(container)"))
            }
            // Go to the possible the next separator index
            currentIndex = container.index(after: nextIndex)
            nextIndex = container.index(after: currentIndex)
        }

        // As the loop breaks at the endIndex, the last token needs to be
        // processed seperatly if the collection ends at the container end
        if nextIndex == container.endIndex {
            try collection.append(branch(container[currentIndex..<nextIndex]).result)
        }

        let consumed = container.distance(from: container.startIndex, to: nextIndex)
        return (result: collection, numberOfElementsConsumed: consumed)
    }
}
