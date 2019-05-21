import Foundation

extension CharacterSet {

    /// Test for membership of a particular `Character` in the `CharacterSet`.
    internal func contains(_ member: Character) -> Bool {
        // FIXME: This is hidden to the public as it needs proper validation if it fits the requirements in tokenization
        return member.unicodeScalars.allSatisfy(contains)
    }
}
