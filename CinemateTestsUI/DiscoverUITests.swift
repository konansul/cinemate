import XCTest

final class DiscoverUITests: UITestCase {
    func testTappingAPosterOpensTheDetailScreen() {
        launchPastOnboarding()
        openFirstMovie()

        XCTAssertTrue(app.buttons["watchedButton"].exists)
        XCTAssertTrue(app.buttons["watchlistButton"].exists)
    }

    func testDetailScreenHidesTheTabBar() {
        launchPastOnboarding()
        openFirstMovie()

        XCTAssertEqual(app.tabBars.count, 0, "The tab bar must not sit on top of the detail screen")
    }

    func testSearchReturnsResults() {
        launchPastOnboarding()
        waitForFirstPoster()

        let field = app.textFields["searchField"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()

        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 10), "Keyboard never appeared")
        let focused = expectation(
            for: NSPredicate(format: "hasKeyboardFocus == true"),
            evaluatedWith: field
        )
        wait(for: [focused], timeout: 10)

        field.typeText("Matrix")

        let result = app.descendants(matching: .any)
            .matching(identifier: "gridPosterCard")
            .firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 20), "Search produced no results")
    }
}
