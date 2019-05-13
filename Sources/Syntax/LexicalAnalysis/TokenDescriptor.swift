import Foundation

public final class TokenDescriptor {

    public var ignoredCharacterSet: CharacterSet

    public private(set) var tokenDescriptions: [TokenDescription]

    public init(ignore: CharacterSet = .whitespacesAndNewlines) {
        ignoredCharacterSet = ignore
        tokenDescriptions = []
    }

    public func append(_ description: TokenDescription) {
        return tokenDescriptions.append(description)
    }

    public func append<S>(contentsOf descriptions: S) where S.Element == TokenDescription, S : Sequence {
        return tokenDescriptions.append(contentsOf: descriptions)
    }

    @discardableResult
    public func remove(at index: Int) -> TokenDescription {
        return tokenDescriptions.remove(at: index)
    }

    public func insert(_ description: TokenDescription, at index: Int) {
        return tokenDescriptions.insert(description, at: index)
    }

    /// Returns the token starting at given index in given scalar sequence and its length in the sequence.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the available descriptions sequence.
    @inlinable public func token(in string: String, at offset: String.Index) throws -> (Token, Int)? {
        for description in tokenDescriptions {
            if let match = try description.token(in: string, at: offset) {
                return match
            }
        }
        return nil
    }
}
