import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SyntaxTests.allTests),
        testCase(ParserTests.allTests),
    ]
}
#endif
