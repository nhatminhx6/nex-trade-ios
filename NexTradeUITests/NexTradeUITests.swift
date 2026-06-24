import XCTest

final class NexTradeUITests: XCTestCase {
    @MainActor
    func testGuestIsPromptedToSignInOnlyWhenSubmittingARequest() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Tìm nguồn"].tap()
        let createRequest = app.buttons["Gửi yêu cầu tìm nguồn"]
        XCTAssertTrue(createRequest.waitForExistence(timeout: 8))
        createRequest.tap()

        let product = app.textFields["Ví dụ: xoài cát, sầu riêng, gạo ST25..."]
        XCTAssertTrue(product.waitForExistence(timeout: 5))
        product.tap()
        product.typeText("Live backend UI test")

        app.buttons["Gửi yêu cầu"].tap()

        let email = app.textFields["name@company.com"]
        XCTAssertTrue(email.waitForExistence(timeout: 5))
        email.tap()
        email.typeText("buyer.demo@nextrade.local")
        app.secureTextFields["Nhập mật khẩu"].tap()
        app.secureTextFields["Nhập mật khẩu"].typeText("DemoPass123!")
        app.buttons["Đăng nhập"].tap()
        XCTAssertTrue(app.alerts["Đã gửi yêu cầu"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testGuestCanBrowseWithoutSigningIn() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing-guest")
        app.launch()

        XCTAssertTrue(app.staticTexts["Yêu cầu đã duyệt"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.textFields["name@company.com"].exists)
    }

    @MainActor
    func testGuestIsAskedToSignInFromSourceCTA() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing-guest")
        app.launch()

        app.tabBars.buttons["Tìm nguồn"].tap()
        let createRequest = app.buttons["Gửi yêu cầu tìm nguồn"]
        XCTAssertTrue(createRequest.waitForExistence(timeout: 5))
        createRequest.tap()

        XCTAssertTrue(app.textFields["name@company.com"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBuyerCanCompleteTheContactSection() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing-authenticated")
        app.launch()

        let createRequest = app.buttons["Gửi yêu cầu tìm nguồn"]
        XCTAssertTrue(createRequest.waitForExistence(timeout: 5))
        createRequest.tap()

        let product = app.textFields["Ví dụ: xoài cát, sầu riêng, gạo ST25..."]
        XCTAssertTrue(product.waitForExistence(timeout: 5))
        product.tap()
        product.typeText("UI test mango")

        let contactName = app.textFields["Tên người liên hệ"]
        contactName.tap()
        contactName.typeText("UI Test Buyer")

        let phone = app.textFields["Số điện thoại"]
        XCTAssertTrue(phone.exists)
        phone.tap()
        phone.typeText("0976999864")

        XCTAssertTrue(app.buttons["Gửi yêu cầu"].exists)
    }
}
