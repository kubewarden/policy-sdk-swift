import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(kubewardenSdkTests.allTests),
    ]
}
#endif
