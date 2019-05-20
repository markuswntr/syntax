import Foundation

/// A type to describe how a token will look like in a string sequence.
public protocol TokenDescriptor {

    /// Evaluates given container against a token that is described by self, returning the first matching
    /// token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The remaining subsequence in the tokenizer to be evaluated.
    func first(in container: String.SubSequence) throws -> (Token, consumedLength: Int)?
}

// MARK: CharacterToken Descriptor

/// A type to find a token of a single character length in a string (subsequence).
public final class CharacterTokenDescriptor: TokenDescriptor {

    /// The raw value, or character, that should be scanned for
    let rawValue: Character

    /// The native type that represents the raw value character
    let nativeType: CharacterToken.Type

    /// Initialises a new instance that scans for given `token`, initialising
    /// a new instance of given `type` on successfully scanning.
    public init(token: Character, type: CharacterToken.Type) {
        rawValue = token
        nativeType = type
    }

    /// Evaluates given container against a token that is described by self, returning the first matching
    /// token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The remaining subsequence in the tokenizer to be evaluated.
    public func first(in container: String.SubSequence) throws -> (Token, consumedLength: Int)? {
        // 1. Compare the character described in self, and the current character in the tokenizing string
        guard let analysee = container.first, analysee == rawValue else { return nil }
        // 2. It they match, try to create a native representation of that character
        guard let token = nativeType.init(value: analysee) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                "Character \(analysee) is not representable as \(nativeType)"))
        }
        // 3. Finish successfully. The token describes a single char, so length equal 1
        return (token, consumedLength: 1)
    }
}
