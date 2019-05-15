import Foundation

public final class NodeDescriptor {

    public private(set) var nodeDescriptions: [NodeDescription]

    public init() {
        nodeDescriptions = []
    }

    public func append(_ description: NodeDescription) {
        return nodeDescriptions.append(description)
    }

    public func append<S>(contentsOf descriptions: S) where S.Element == NodeDescription, S : Sequence {
        return nodeDescriptions.append(contentsOf: descriptions)
    }

    @discardableResult
    public func remove(at index: Int) -> NodeDescription {
        return nodeDescriptions.remove(at: index)
    }

    public func insert(_ description: NodeDescription, at index: Int) {
        return nodeDescriptions.insert(description, at: index)
    }

    @usableFromInline
    func node<Container: Collection>(
        for container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token {
        for description in nodeDescriptions {
            if let match = try description.node(for: container, analyse: subContainer) {
                return match
            }
        }
        return nil
    }
}
