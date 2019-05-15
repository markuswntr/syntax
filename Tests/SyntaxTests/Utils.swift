import Syntax
import Foundation

// MARK: "Models"

extension Substring: Token {}
extension String: Node {}
extension Double: Node {}

enum CharacterToken: Character, CaseIterable, Token {
    case parentheseOpen = "("
    case parentheseClose = ")"
    case bracketOpen = "["
    case bracketClose = "]"
    case collectionSeparator = ","
}

enum CharacterSetToken: Token {
    case number(Substring)
    case name(Substring)
}

// MARK: Descriptions

extension CharacterToken: TokenDescription {

    func token(in string: String, at offset: String.Index) throws -> (Token, length: Int)? {
        guard rawValue == string[offset] else { return nil }
        return (self, 1) // Found self in given string at current offset. A single character, so length == 1
    }
}

final class CharacterSetDescription: TokenDescription, NodeDescription {

    // MARK: NodeDescription

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

    // MARK: TokenDescription

    func token(in string: String, at offset: String.Index) throws -> (Token, length: Int)? {
        if let substring = try find(pattern: .decimalDigits, in: string, at: offset) {
            return (CharacterSetToken.number(substring), substring.count)
        } else if let substring = try find(pattern: .letters, in: string, at: offset) {
            return (CharacterSetToken.name(substring), substring.count)
        }
        return nil
    }

    private func find(pattern: CharacterSet, in string: String, at offset: String.Index) throws -> Substring? {
        // First character must match the set directly, otherwise it cannot be valid
        guard string[offset].unicodeScalars.allSatisfy(pattern.contains) else {
            return nil
        }

        var currentOffset = string.index(after: offset) //  Advance to the second character right away
        while currentOffset < string.endIndex, string[currentOffset].unicodeScalars.allSatisfy(pattern.contains) {
            currentOffset = string.index(after: currentOffset)
        }

        return string[offset..<currentOffset]
    }
}

final class StringTokenDescription: TokenDescription {

    func token(in string: String, at offset: String.Index) throws -> (Token, length: Int)? {
        guard string[offset] == "\"" else { return nil }

        var currentOffset = string.index(after: offset) // Current char is a quote, so go to the next char right away
        while currentOffset < string.endIndex, string[currentOffset] != "\"" {
            currentOffset = string.index(after: currentOffset)
        }

        // Perform a validation on both loop terminations. The loop must end on a quote ("), not on the end index.
        guard currentOffset < string.endIndex && string[currentOffset] == "\"" else {
            let startIndex = offset.utf16Offset(in: string)
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "Found an unterminated string, starting at \(startIndex)"))
        }
        // "Manually" advance by one character, as the loop above ends scanning ON the trailing quote (").
        // Advancing the index by one character will include the quote (") accordingly.
        currentOffset = string.index(after: currentOffset)
        let substring = string[offset..<currentOffset]
        return (substring, substring.count)
    }
}


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
