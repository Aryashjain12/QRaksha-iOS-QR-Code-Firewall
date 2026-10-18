import XCTest
@testable import QRaksha

final class URLRiskAnalyzerTests: XCTestCase {
    private let analyzer = URLRiskAnalyzer()

    func testAddsHTTPSToBareDomain() {
        let result = analyzer.analyze("example.com")
        XCTAssertEqual(result.normalizedURL?.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
    }

    func testFlagsHTTP() {
        let result = analyzer.analyze("http://example.com")
        XCTAssertTrue(result.findings.contains { $0.title == "Connection is not HTTPS" })
    }

    func testFlagsIPHost() {
        let result = analyzer.analyze("http://192.0.2.10/login")
        XCTAssertTrue(result.findings.contains { $0.title == "IP address used as host" })
    }

    func testShowsActualHostname() {
        let result = analyzer.analyze("https://paypal.com.example.org/login")
        XCTAssertEqual(result.host, "paypal.com.example.org")
        XCTAssertTrue(result.findings.contains { $0.title == "Possible brand impersonation pattern" })
    }

    func testRejectsUnsupportedScheme() {
        let result = analyzer.analyze("javascript:alert(1)")
        XCTAssertNil(result.normalizedURL)
        XCTAssertEqual(result.level, .invalid)
    }

    func testEmptyInputIsInvalid() {
        let result = analyzer.analyze("   ")
        XCTAssertNil(result.normalizedURL)
        XCTAssertEqual(result.level, .invalid)
    }

    func testFlagsEmbeddedUserInfo() {
        let result = analyzer.analyze("https://trusted.example@evil.example/login")
        XCTAssertTrue(result.findings.contains { $0.title == "Embedded credentials or user-info" })
        XCTAssertEqual(result.host, "evil.example")
    }

    func testFlagsKnownShortener() {
        let result = analyzer.analyze("https://bit.ly/example")
        XCTAssertTrue(result.findings.contains { $0.title == "Shortened URL" })
    }

    func testLowScoreIsNotClaimedAsSafe() {
        let result = analyzer.analyze("https://example.com")
        XCTAssertTrue(result.recommendedAction.localizedCaseInsensitiveContains("does not guarantee"))
    }

    func testPreservesHTTPSPathAndQuery() {
        let result = analyzer.analyze("https://example.com/events?id=7")
        XCTAssertEqual(result.normalizedURL?.path, "/events")
        XCTAssertEqual(result.normalizedURL?.query, "id=7")
    }
}
