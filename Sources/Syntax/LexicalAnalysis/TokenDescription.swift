import Foundation

/// A type to describe how a token will look like in a string sequence.
public protocol TokenDescription {

    /// Evaluates given container against a token that is described by self, returning the first matching
    /// token and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - parameter container: The remaining subsequence in the tokenizer to be evaluated.
    func firstToken(in container: String.SubSequence) throws -> (Token, consumedLength: Int)?
}
