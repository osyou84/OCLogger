import XCTest
@testable import OCLogger

// @Sendable クロージャ内でミュータブルな値をキャプチャするためのラッパー
private final class Capture<T: Sendable>: @unchecked Sendable {
    var value: T
    init(_ initial: T) { self.value = initial }
}

final class OCLoggerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        OCLogger.minimumLevel = .verbose
        OCLogger.showTimestamp = true
        OCLogger.removeAllHandlers()
    }

    // MARK: - 基本ログ出力

    func testPrintVerboseLog() {
        XCTAssertNoThrow(OCLogger.verbose("testPrintVerboseLog"))
    }

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

    // MARK: - ログレベルフィルタリング

    func testMinimumLevelFiltersLowerLevels() {
        OCLogger.minimumLevel = .warn
        let called = Capture(false)
        OCLogger.addHandler { _, _ in called.value = true }

        OCLogger.debug("should be filtered")
        OCLogger.info("should be filtered")
        XCTAssertFalse(called.value, "warn 未満のログはハンドラーが呼ばれないはず")

        OCLogger.warn("should pass")
        XCTAssertTrue(called.value, "warn 以上のログはハンドラーが呼ばれるはず")
    }

    func testMinimumLevelAllowsEqualLevel() {
        OCLogger.minimumLevel = .error
        let called = Capture(false)
        OCLogger.addHandler { _, _ in called.value = true }

        OCLogger.error("should pass")
        XCTAssertTrue(called.value)
    }

    // MARK: - カスタムハンドラー

    func testCustomHandlerReceivesLogLevel() {
        let receivedLevel = Capture<LogLevel?>(.none)
        OCLogger.addHandler { level, _ in receivedLevel.value = level }

        OCLogger.info("handler test")
        XCTAssertEqual(receivedLevel.value, .info)
    }

    func testCustomHandlerReceivesMessage() {
        let receivedMessage = Capture<String?>(.none)
        OCLogger.addHandler { _, message in receivedMessage.value = message }

        OCLogger.debug("hello handler")
        XCTAssertTrue(receivedMessage.value?.contains("hello handler") == true)
    }

    // MARK: - タイムスタンプ

    func testTimestampIncludedWhenEnabled() {
        OCLogger.showTimestamp = true
        let receivedMessage = Capture<String?>(.none)
        OCLogger.addHandler { _, message in receivedMessage.value = message }

        OCLogger.info("ts test")
        XCTAssertTrue(receivedMessage.value?.contains("202") == true, "タイムスタンプが含まれるはず")
    }

    func testTimestampExcludedWhenDisabled() {
        OCLogger.showTimestamp = false
        let receivedMessage = Capture<String?>(.none)
        OCLogger.addHandler { _, message in receivedMessage.value = message }

        OCLogger.info("no ts test")
        XCTAssertFalse(receivedMessage.value?.contains("202") == true, "タイムスタンプが含まれないはず")
    }

    // MARK: - LogLevel Comparable

    func testLogLevelComparable() {
        XCTAssertTrue(LogLevel.verbose < LogLevel.debug)
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.warn)
        XCTAssertTrue(LogLevel.warn < LogLevel.error)
        XCTAssertFalse(LogLevel.error < LogLevel.warn)
    }
}
