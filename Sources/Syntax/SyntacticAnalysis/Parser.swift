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
    public func analyse<Container: Collection>(container: Container) throws -> Node where Container.Element == Token {

        var nodes: [Node] = []
        var offset = container.startIndex
        while offset < container.endIndex {

            let remainder = container[offset...]
            guard let (node, consumed) = try firstNode(in: remainder, analyse: analyse(container:)) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
                    "Invalid token \(container[offset]) at index \(offset)"))
            }

            offset = container.index(offset, offsetBy: consumed)
            nodes.append(node)
        }

        // Make sure there IS an actual node description in the container
        guard !nodes.isEmpty else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "There are no nodes represented in token container"))
        }

        // Make sure this is an array node, otherwise return the node directly and avoid invalid collection boxing
        return nodes.count > 1 ? nodes : nodes[nodes.startIndex]
    }
}


// MARK: - Evaluating Descriptions
extension Parser {

    /// Returns the node starting at given container
    ///
    /// - Complexity: O(*n*), where *n* is the length of the available descriptions sequence.
    @usableFromInline func firstNode<Container: Collection>(
        in container: Container,
        analyse branch: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {
        for descriptor in descriptors {
            if let match = try descriptor.first(in: container, analyse: analyse(container:)) {
                return match
            }
        }
        return nil
    }
}
