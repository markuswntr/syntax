import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TokenizerTests.allTests),
        testCase(ParserTests.allTests)
    ]
}
#endif
