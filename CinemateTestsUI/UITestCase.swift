import XCTest

class UITestCase: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func launchPastOnboarding() {
        app.launchArguments = ["-hasCompletedOnboarding", "YES", "-skipNotificationPrompt"]
        app.launch()
    }

    func launchAtOnboarding() {
        app.launchArguments = ["-resetOnboarding", "-skipNotificationPrompt"]
        app.launch()
    }

    @discardableResult
    func waitForFirstPoster(timeout: TimeInterval = 30) -> XCUIElement {
        let poster = app.descendants(matching: .any)
            .matching(identifier: "posterCard")
            .firstMatch
        XCTAssertTrue(poster.waitForExistence(timeout: timeout), "Discover never finished loading")
        return poster
    }

    func openFirstMovie() {
        waitForFirstPoster().tap()
        XCTAssertTrue(
            app.buttons["favoriteButton"].waitForExistence(timeout: 10),
            "Tapping a poster did not open a detail screen"
        )
    }
}
