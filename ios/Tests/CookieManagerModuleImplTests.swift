import XCTest
import React
@testable import react_native_cookies

final class CookieManagerModuleImplTests: XCTestCase {
    private var module: CookieManagerModuleImpl!

    override func setUp() {
        super.setUp()
        module = CookieManagerModuleImpl()
        clearCookies()
    }

    override func tearDown() {
        clearCookies()
        module = nil
        super.tearDown()
    }

    func testSetRejectsMismatchedDomain() {
        let expectation = expectation(description: "reject called")
        let cookie: NSDictionary = [
            "name": "session",
            "value": "value",
            "domain": "other.com"
        ]

        module.set(url: URL(string: "https://example.com")!,
                   cookie: cookie,
                   useWebKit: false,
                   resolver: { _ in
                       XCTFail("Expected rejection for mismatched domain")
                   },
                   rejecter: { _, message, _ in
                       XCTAssertEqual(message, "Cookie URL host example.com and domain other.com mismatched. The cookie won't set correctly.")
                       expectation.fulfill()
                   })

        waitForExpectations(timeout: 1)
    }

    func testClearByNameRemovesCookie() {
        let setExpectation = expectation(description: "set cookie")
        let url = URL(string: "https://example.com")!
        let cookie: NSDictionary = [
            "name": "session",
            "value": "value"
        ]

        module.set(url: url,
                   cookie: cookie,
                   useWebKit: false,
                   resolver: { value in
                       XCTAssertEqual(value as? Bool, true)
                       setExpectation.fulfill()
                   },
                   rejecter: { _, message, _ in
                       XCTFail("Unexpected rejection: \(message ?? "")")
                   })

        waitForExpectations(timeout: 1)

        XCTAssertTrue(HTTPCookieStorage.shared.cookies?.contains(where: { $0.name == "session" }) ?? false)

        let clearExpectation = expectation(description: "clear cookie")
        module.clearByName(url: url,
                           name: "session",
                           useWebKit: false,
                           resolver: { value in
                               XCTAssertEqual(value as? Bool, true)
                               clearExpectation.fulfill()
                           },
                           rejecter: { _, message, _ in
                               XCTFail("Unexpected rejection: \(message ?? "")")
                           })

        waitForExpectations(timeout: 1)

        XCTAssertFalse(HTTPCookieStorage.shared.cookies?.contains(where: { $0.name == "session" }) ?? true)
    }

    private func clearCookies() {
        let storage = HTTPCookieStorage.shared
        storage.cookies?.forEach { storage.deleteCookie($0) }
    }
}