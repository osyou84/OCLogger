import XCTest
@testable import OCLogger

final class OCLoggerTests: XCTestCase {
    func testPrintDebugLog() {
        XCTAssertNoThrow(OCLogger.debug("testPrintDebugLog"))
    }
    
    func testPrintInfoLog() {
        XCTAssertNoThrow(OCLogger.info("testPrintInfoLog"))
    }
    
    func testPrintWarnLog() {
        XCTAssertNoThrow(OCLogger.warn("testPrintWarnLog"))
    }
    
    func testPrintErrorLog() {
        XCTAssertNoThrow(OCLogger.error("testPrintErrorLog"))
    }
}
