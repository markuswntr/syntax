import Foundation

/// Right now, a token does not have any requirement(s), but rather its inheriting protocols.
/// However, to avoid problems once token are evolving, there is a protocol in place already.
public protocol Token {
}

// MARK: Character Token

/// A token that consists of exactly one single character, e.g. parentheses, colon, semicolon, ...
public protocol CharacterToken: Token {

    /// The initializer takes a matching character found while tokenization
    init?(value: Character)
}

extension CharacterToken where Self: RawRepresentable, RawValue == Character {

    /// Forwards the initializer to the raw initializer if it is a raw representable, i.e. Char enum
    public init?(value: Character) {
        self.init(rawValue: value)
    }
}

// MARK: Keyword Token

/// A token that is of 2-n characters in length and is described by a static string aka keyword.
///
/// A static string example might be keywords like `if`, `for`, `switch` in traditonal programming languages.
public protocol KeywordToken: Token {

    /// The initializer takes the keyword as string
    init?(value: String)
}

extension KeywordToken where Self: RawRepresentable, RawValue == String {

    /// Forwards the initializer to the raw initializer if it is a raw representable, i.e. String enum
    public init?(value: String) {
        self.init(rawValue: value)
    }
}

// MARK: Pattern Token

/// A token that is of 2-n characters in length and is described a regular expression.
///
/// A Regular expression based pattern token might be variable names in traditonal programming languages.
public protocol PatternToken: Token {

    /// The initializer takes the found string subsequence as argument
    ///
    /// - Note: The subsequence is still just pointing to a range in its base, extracting it will descrease performance.
    init?(value: String.SubSequence)
}
