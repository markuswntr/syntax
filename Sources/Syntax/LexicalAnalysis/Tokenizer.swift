import Foundation

// The tokenizer converts an input string data into an array of string tokens (aka “Lexical Analysis”).
public struct Tokenizer {

    /// The descriptor against which to evaluate possible tokens
    private let descriptor: TokenDescriptor

    /// Initializes a new tokenizer utilizing the configuration and token descriptions from given descriptor.
    ///
    /// Tokenizer can not be reused. They are bound to the descriptor passed via this initializer.
    /// This is a lightweight initializer that only stores references of given values.
    public init(descriptor: TokenDescriptor) {
        self.descriptor = descriptor
    }

    /// Analyses given string `data` of string `encoding` using the descriptor
    /// passed upon initialisation and returns the tokens found in order.
    @inlinable public func analyse(data: Data, encoding: String.Encoding = .utf8) throws -> [Token] {
        return try analyse(string: expectString(from: data, encoding: encoding))
    }

    /// Analyses given `string` using the descriptor passed upon initialisation and returns the tokens found in order.
    public func analyse(string: String) throws -> [Token] {
        let analysee = try expectTokenizableString(string: string)

        var tokens: [Token] = []
        var offset = analysee.startIndex

        while offset < analysee.endIndex {

            // Test if character is an ignorable character (e.g. whitespace or newline character)
            guard !(analysee[offset].unicodeScalars.allSatisfy(descriptor.ignoredCharacterSet.contains)) else {
                offset = analysee.index(after: offset) // Skip this character, as it should be ignored
                continue
            }

            // Find the token starting at current index, and its length in the string sequence
            guard let (token, length) = try descriptor.token(in: analysee, at: offset) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                    "Invalid character \(analysee[offset]) at index \(offset.utf16Offset(in: analysee))"))
            }

            // Advance to the next character that starts after the last found token
            offset = analysee.index(offset, offsetBy: length)
            tokens.append(token) // and backup the last found token
        }

        guard !tokens.isEmpty else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "There are no tokens in given data."))
        }

        return tokens
    }
}

// MARK: Validation & Decoding
extension Tokenizer {

    /// Decodes given data using given string encoding and returns the result only if valid. Throws an error otherwise.
    @usableFromInline internal func expectString(from data: Data, encoding: String.Encoding) throws -> String {
        guard !data.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "The given data is empty."))
        }
        guard let string = String(data: data, encoding: encoding) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "The given data is not \(encoding) encoded."))
        }
        return string
    }

    /// Performs validation steps on the string and returns the result only if valid. Throws an error otherwise.
    @usableFromInline internal func expectTokenizableString(string: String) throws -> String {
        guard !string.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "The given string is of invalid length."))
        }
        return string
    }
}
