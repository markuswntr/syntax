import Foundation

/// A type to describe how a token will look like in a string sequence.
public protocol TokenDescriptor {

    /// Evaluates given container against a token that is described by self, returning the first matching
    /// token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The current state of the tokenizer containing remaining values to be evaluated.
    func first(in container: Tokenizer.Container) throws -> Analysis<Token>?
}

// MARK: CharacterToken Descriptor

/// A type to find a token of a single character length in a string (subsequence).
public final class CharacterTokenDescriptor: TokenDescriptor {

    /// The raw value, or character, that should be scanned for
    private let rawValue: Character

    /// The native type that represents the raw value character
    private let nativeType: CharacterToken.Type

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
    public func first(in container: Tokenizer.Container) throws -> Analysis<Token>? {
        // 1. Compare the character described in self, and the current character in the tokenizing string
        guard let analysee = container.remainder.first, analysee == rawValue else { return nil }
        // 2. It they match, try to create a native representation of that character
        guard let token = nativeType.init(token: analysee) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                "Character \(analysee) is not representable as \(nativeType)"))
        }
        // 3. Finish successfully. The token describes a single char, so length equal 1
        return (result: token, numberOfElementsConsumed: 1)
    }
}

// MARK: KeywordToken Descriptor

public final class KeywordTokenDescriptor: TokenDescriptor {

    /// The keyword that should be scanned for
    private let rawValue: String

    /// The native type that represents the raw value pattern
    private let nativeType: KeywordToken.Type

    /// Initialises a new instance that scans for given `keyword`.
    ///
    /// The descriptor will return an instance of given `type` on successfully scanning.
    public init(token: String, type: KeywordToken.Type) throws {
        guard !token.isEmpty else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                "The keyword <\(token)> passed to the descriptor must not be empty."))
        }
        rawValue = token
        nativeType = type
    }

    /// Evaluates given container against a token that is described by self, returning the first matching
    /// token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The remaining subsequence in the tokenizer to be evaluated.
    public func first(in container: Tokenizer.Container) throws -> Analysis<Token>? {
        guard container.remainder.starts(with: rawValue) else { return nil }
        // Use `rawValue` rather than the container to avoid extraction
        guard let token = nativeType.init(token: rawValue) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                "Keyword \(rawValue) is not representable as \(nativeType)"))
        }
        return (result: token, numberOfElementsConsumed: rawValue.count)
    }
}

// MARK: PatternToken Descriptor

public final class PatternTokenDescriptor: TokenDescriptor {

    /// The pattern that should be scanned for
    private let regex: NSRegularExpression

    /// The native type that represents the raw value pattern
    private let nativeType: PatternToken.Type

    /// Initialises a new instance that scans for patterns using given regular expression.
    ///
    /// The descriptor will return an instance of given `type` on successfully scanning.
    public init(regularExpression: NSRegularExpression, type: PatternToken.Type) {
        regex = regularExpression
        nativeType = type
    }

    /// Evaluates given container against a token that is described by self, returning the first matching
    /// token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The remaining subsequence in the tokenizer to be evaluated.
    public func first(in container: Tokenizer.Container) throws -> Analysis<Token>? {

        let remainingRange = NSRange(container.offset..., in: container.base)
        let firstMatch = regex.firstMatch(in: container.base, options: .anchored, range: remainingRange)
        guard let result = firstMatch, result.range.location != NSNotFound, result.range.length != 0 else { return nil }
        guard let rawValueRange = Range(result.range, in: container.base) else { return nil }

        let rawValue = container.base[rawValueRange]
        guard let token = nativeType.init(token: rawValue) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                "Pattern \(rawValue) is not representable as \(nativeType)"))
        }
        return (result: token, numberOfElementsConsumed: rawValue.count)
    }
}

// MARK: CollectionToken Descriptor

/// An array may be used as token descriptor if all elements are token descriptors. The first to match wins.
extension Array: TokenDescriptor where Element: TokenDescriptor {

    /// Evaluates given container against a token that is described by any of the containing token descriptors,
    /// returning the first matching token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The remaining subsequence in the tokenizer to be evaluated.
    @inlinable public func first(in container: Tokenizer.Container) throws -> Analysis<Token>? {
        for tokenizer in self {
            if let token = try tokenizer.first(in: container) {
                return token
            }
        }
        return nil
    }
}
