import XCTest
@testable import UsewiseSwift

final class UsewiseTests: XCTestCase {
    func testInitialization() {
        Usewise.initialize(config: UsewiseConfig(apiKey: "test_key"))
        XCTAssertNotNil(Usewise.shared)
        XCTAssertFalse(Usewise.shared!.currentAnonymousId.isEmpty)
        XCTAssertNil(Usewise.shared!.currentUserId)
        XCTAssertFalse(Usewise.shared!.isOptedOut)
    }
}
