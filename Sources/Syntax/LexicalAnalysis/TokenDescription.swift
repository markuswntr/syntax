import Foundation

public protocol Token {}

public protocol TokenDescription {

    func token(in string: String, at offset: String.Index) throws -> (Syntax.Token, length: Int)?
}
