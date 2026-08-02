import XCTest

final class OnboardingUITests: UITestCase {
    func testSkipGoesStraightToDiscover() {
        launchAtOnboarding()

        let skip = app.buttons["Skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 10))
        skip.tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
    }

    func testPagingThroughReachesGetStarted() {
        launchAtOnboarding()

        let cont = app.buttons["Continue"]
        XCTAssertTrue(cont.waitForExistence(timeout: 10))
        cont.tap()
        cont.tap()

        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Skip"].exists, "Skip should disappear on the last page")

        getStarted.tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
    }

    func testOnboardingDoesNotReturnOnTheNextLaunch() {
        launchAtOnboarding()
        app.buttons["Skip"].tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))

        app.terminate()
        app.launchArguments = ["-skipNotificationPrompt"]
        app.launch()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Continue"].exists)
    }
}
