import XCTest

import kubewardenSdkTests

var tests = [XCTestCaseEntry]()
tests += kubewardenSdkTests.allTests()
XCTMain(tests)
