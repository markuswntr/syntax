import Foundation

/// Right now, a node does not have any requirement(s), but rather its inheriting protocols.
/// However, to avoid problems once nodes are evolving, there is a protocol in place already.
public protocol Node {
}

extension Array: Node {}
