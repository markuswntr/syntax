import Foundation

// The tokenizer converts an input string data into an array of string tokens (aka “Lexical Analysis”).
public struct Tokenizer {

    /// The input type that holds the value reference to be analysed
    fileprivate enum Analysee {
        case data(Data, encoding: String.Encoding)
        case string(String)
    }

    /// The input value to be tokenized
    private let analysee: Analysee

    /// Initializes a new tokenizer over given string data using given encoding upon reading.
    ///
    /// Tokenizer can not be reused. They are bound to the data passed via this initializer.
    /// This is a lightweight initializer that only stores the references of given values.
    public init(over data: Data, encoding: String.Encoding = .utf8) {
        analysee = .data(data, encoding: encoding)
    }

    /// Initializes a new tokenizer over given string.
    ///
    /// Tokenizer can not be reused. They are bound to the string passed via this initializer.
    /// This is a lightweight initializer that only stores a reference to given string value.
    public init(over string: String) {
        analysee = .string(string)
    }

    /// Analyses the `analysee` passed to the tokenizer on initialisation using given
    /// description and returns the tokens found within the `analysee` in order.
    public func analyse(using descriptor: TokenDescriptor) throws -> [Token] {
        let analysee = try expectNonEmptyString(from: self.analysee)

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

    /// Decodes data from analysee, or uses wrapping string directly, performs pre-validation on the string
    /// and returning the result only if all validation steps succeeded. Throws an error otherwise.
    fileprivate func expectNonEmptyString(from analysee: Analysee) throws -> String {
        let stringValue: String
        switch analysee {
        case let .data(data, encoding: encoding):
            stringValue = try decode(data: data, encoding: encoding)
        case let .string(string):
            stringValue = string
        }

        guard !stringValue.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "The given string is of invalid length."))
        }
        return stringValue
    }

    /// Decodes given data using given string encoding, performs validation steps and returns the result
    /// only if all validation steps finished successfully. Throws an error otherwise.
    private func decode(data: Data, encoding: String.Encoding) throws -> String {
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
}
