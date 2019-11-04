import Foundation

extension CharacterSet {

    /// Test for membership of a particular `Character` in the `CharacterSet`.
    ///
    /// - Note: Do not expose it publicly. It is really only useful inside the tokenizer.
    internal func contains(_ member: Character) -> Bool {
        member.unicodeScalars.allSatisfy(contains)
    }
}
