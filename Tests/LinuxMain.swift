import XCTest

import SyntaxTests

var tests = [XCTestCaseEntry]()
tests += SyntaxTests.allTests()
XCTMain(tests)
