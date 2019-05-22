import Foundation

/// A type to describe how a node will look like based of one or several token.
public protocol NodeDescriptor {

    /// Evaluates given container against a node that is described by self, returning the first matching
    /// node and its consuming length in the container on success, `nil` otherwise.
    ///
    /// - Parameters:
    ///   - container: The remaining container to be evaluated by this descriptor
    ///   - branch: A function pointer to be used if the nodes needs one or more branches to be analysed.
    /// - Returns: The node found in the container, `nil` otherwise.
    /// - Throws: An error if the container does not start with tokens that can be described as nodes by this descriptor
    func first<Container: Collection>(
        in container: Container,
        analyse branch: (Container.SubSequence) throws -> Analysis<Node>
    ) throws -> Analysis<Node>? where Container.Element == Token
}
