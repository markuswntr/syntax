import Foundation

/// A analysing result type. It will hold the resulting type found as well as the elements it consumed in the process.
///
/// For `Token` based results the result value is of `Token` type, the `numberOfElementsConsumed` is the number
/// of characters it took to form this token, i.e *2* for a keyword like `if`, *1* for control chars like `;`
///
/// For `Node` based results the result value is of `Node` type, the `numberOfElementsConsumed` is the number
/// of tokens it took to form this node *AND* branches in this node.
public typealias Analysis<Type> = (result: Type, numberOfElementsConsumed: Int)
