import Foundation

extension Array: Node {}

/// The parser transforms an array of tokens into an Abstract Syntax Tree (AST) - aka "Syntactic Analysis"
public struct Parser {

    /// The descriptor against which to evaluate possible nodes
    private let descriptor: NodeDescriptor

    /// Initializes a new parser that utilizes the configuration and token descriptions from given descriptor.
    ///
    /// Parser can not be reused. They are bound to the descriptor passed via this initializer.
    /// This is a lightweight initializer that only stores references of given values.
    public init(descriptor: NodeDescriptor) {
        self.descriptor = descriptor
    }

    /// Analyses given `container` of tokens using the descriptor passed upon
    /// initialisation and returns the nodes as an abstract syntax tree.
    public func analyse<Container: Collection>(container: Container) throws -> Node where Container.Element == Token {

        var nodes: [Node] = []
        var offset = container.startIndex
        while offset < container.endIndex {

            let remainder = container[offset..<container.endIndex]
            guard let (node, consumed) = try descriptor.node(for: remainder, analyse: analyse(container:)) else {
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
