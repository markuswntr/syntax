import Foundation

extension Tokenizer {

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
}
