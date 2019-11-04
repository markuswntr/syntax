import Foundation

/// Right now, a token does not have any requirement(s), but rather its inheriting protocols.
/// However, to avoid problems once token are evolving, there is a protocol in place already.
public protocol Token {
}

// MARK: Character Token

/// A token that consists of exactly one single character, e.g. parentheses, colon, semicolon, ...
public protocol CharacterToken: Token {

    /// The initializer takes a matching character found while tokenizing
    init?(token: Character)
}

extension CharacterToken where Self: RawRepresentable, Self.RawValue == Character {

    /// Forwards the initializer to the raw value initializer if it is raw representable, i.e. char enum
    @inlinable public init?(token: Character) {
        self.init(rawValue: token)
    }
}

// MARK: Keyword Token

/// A token that is of 2-n characters in length and is described by a keyword (aka keyword).
///
/// An example of a keyword token might be `if`, `for`, `switch` – in traditonal programming languages.
public protocol KeywordToken: Token {

    /// The initializer takes the keyword as string
    init?(token: String)
}

extension KeywordToken where Self: RawRepresentable, Self.RawValue == String {

    /// Forwards the initializer to the raw value initializer if it is raw representable, i.e. String enum
    public init?(token: String) {
        self.init(rawValue: token)
    }
}

// MARK: Pattern Token

/// A token that is of 2-n characters in length and is described a regular expression.
///
/// A Regular expression based pattern token might be variable names in traditonal programming languages.
public protocol PatternToken: Token {

    /// The initializer takes the matching string subsequence as argument
    ///
    /// - Note: The subsequence is still just pointing to a range in its base. Extracting it will descrease performance.
    init?(token: String.SubSequence)
}
