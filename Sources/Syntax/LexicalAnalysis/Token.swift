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
