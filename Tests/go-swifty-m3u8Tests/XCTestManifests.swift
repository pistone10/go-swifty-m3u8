import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(go_swifty_m3u8Tests.allTests),
    ]
}
#endif
