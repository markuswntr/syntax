import Foundation

/// The parser transforms an array of tokens into an Abstract Syntax Tree (AST) - aka "Syntactic Analysis"
public struct Parser {

    /// The descriptor against which to evaluate possible nodes
    private let descriptors: [NodeDescriptor]

    /// Initializes a new parser that utilizes the configuration and token descriptions from given descriptor.
    ///
    /// Parser can not be reused. They are bound to the descriptor passed via this initializer.
    /// This is a lightweight initializer that only stores references of given values.
    public init(descriptors: [NodeDescriptor]) {
        self.descriptors = descriptors
    }

    /// Analyses given `container` of tokens using the descriptor passed upon
    /// initialisation and returns the nodes as an abstract syntax tree.
    public func analyse<Container: Collection>(container: Container) throws -> [Node] where Container.Element == Token {

        var rootNodes: [Node] = []

        var offset = container.startIndex
        while offset < container.endIndex {
            let remainder = container[offset...]
            let (node, consumed) = try first(in: remainder)
            offset = container.index(offset, offsetBy: consumed)
            rootNodes.append(node)
        }

        // Make sure there is an actual node description in the container
        guard !rootNodes.isEmpty else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "There are no nodes represented in token container"))
        }

        return rootNodes
    }
}


// MARK: - Evaluating Descriptions
extension Parser {

    /// Returns the node starting at given container
    ///
    /// - Complexity: O(*n*), where *n* is the length of the available descriptions sequence.
    @usableFromInline
    func first<Container: Collection>(
        in container: Container
    ) throws -> Analysis<Node> where Container.Element == Token {
        for descriptor in descriptors {
            if let match = try descriptor.first(in: container, analyse: first) {
                return match
            }
        }
        throw DecodingError.dataCorrupted(.init(
            codingPath: [], debugDescription: "Invalid token \(container[container.startIndex])"))
    }
}
