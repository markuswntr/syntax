import Syntax
import Foundation

enum CharacterToken: Character, CaseIterable, Token, TokenDescription {
    case parentheseOpen = "("
    case parentheseClose = ")"
    case bracketOpen = "["
    case bracketClose = "]"
    case collectionSeperator = ","

    func token(in string: String, at offset: String.Index) throws -> (Token, length: Int)? {
        guard rawValue == string[offset] else { return nil }
        return (self, 1) // Found self in given string at current offset. A single character, so length == 1
    }
}

enum CharacterSetToken: Token {
    case number(Substring)
    case name(Substring)
}

final class CharacterSetTokenDescription: TokenDescription {

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

extension Substring: Token {}
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
