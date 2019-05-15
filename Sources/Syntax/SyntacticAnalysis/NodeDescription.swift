import Foundation

public protocol NodeDescription {

    func node<Container: Collection>(
        for container: Container,
        analyse subContainer: (Container.SubSequence) throws -> Node
    ) throws -> (Node, consumedToken: Int)? where Container.Element == Token
}
