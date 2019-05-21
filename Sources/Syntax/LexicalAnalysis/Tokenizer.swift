import Foundation

/// The tokenizer converts an input string data into an array of string tokens (aka “Lexical Analysis”).
public struct Tokenizer {

    /// A container holding the current state of tokenizer process
    public final class Container {

        /// The base string that the container is analysing
        public let base: String

        /// The current offset in the base string. Everything up to the offset is analysed.
        public let offset: String.Index

        /// The remaining subsequence to still be analysed in the process
        public lazy var remainder: String.SubSequence = base[offset...]

        fileprivate init(base: String, offset: String.Index) {
            self.base = base
            self.offset = offset
        }
    }

    /// Configuration of a tokenizer instance.
    ///
    /// Use the configuration to define characters that should be ignored by the tokenizer
    public struct Configuration {

        /// The characters to be ignored while scanning for tokens.
        ///
        /// These characters may still appear inside token descriptions, but are never the start of a new token.
        /// Common examples are be whitespaces and newline characters outside of strings.
        public var ignoredCharacters: CharacterSet

        /// Initializes a new configuration with given properties.
        ///
        /// - parameter ignoredCharacters: A set of characters to ignore while scanning for
        ///             the start of a new token. Defaults to `.whitespaceAndNewlines`.
        public init(ignoredCharacters: CharacterSet = .whitespacesAndNewlines) {
            self.ignoredCharacters = ignoredCharacters
        }
    }

    /// The additional configuration of the tokenizer
    public let configuration: Configuration


    /// The descriptors of tokens against which to evaluate
    public let descriptors: [TokenDescriptor]

    // MARK: Designated Initializer

    /// Initializes a new tokenizer utilizing the configuration and token descriptions from given descriptor.
    ///
    /// Tokenizer can not be reused. They are bound to the descriptor passed via this initializer.
    /// This is a lightweight initializer that only stores references of given values.
    public init(descriptors: [TokenDescriptor], configuration: Configuration = .init()) {
        self.configuration = configuration
        self.descriptors = descriptors
    }

    // MARK: Analysing

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
            guard !(analysee[offset].unicodeScalars.allSatisfy(configuration.ignoredCharacters.contains)) else {
                offset = analysee.index(after: offset) // Skip this character, as it should be ignored
                continue
            }

            // Find the first token in the remaining string and its consuming length
            let container = Container(base: string, offset: offset)
            guard let (token, consumed) = try firstToken(in: container) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                    "Invalid character \(analysee[offset]) at index \(offset.utf16Offset(in: analysee))"))
            }

            // Advance to the next character that starts after the last found token
            offset = analysee.index(offset, offsetBy: consumed)
            tokens.append(token) // and backup the last found token
        }

        guard !tokens.isEmpty else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "There are no tokens in given data."))
        }

        return tokens
    }
}

// MARK: - Validation & Decoding
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

// MARK: - Evaluating Descriptions
extension Tokenizer {

    /// Returns the token starting at given index in given string
    ///
    /// - Complexity: O(*n*), where *n* is the length of the available descriptions sequence.
    @usableFromInline func firstToken(in container: Container) throws -> (Token, consumedLength: Int)? {
        for descriptor in descriptors {
            if let match = try descriptor.first(in: container) {
                return match
            }
        }
        return nil
    }
}
