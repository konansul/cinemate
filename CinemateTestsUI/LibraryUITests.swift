import XCTest

final class LibraryUITests: UITestCase {
    func testFavoritingAMovieAddsItToTheLibrary() {
        launchPastOnboarding()
        openFirstMovie()

        let title = app.staticTexts.element(boundBy: 0).label
        app.buttons["favoriteButton"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.tabBars.buttons["Library"].tap()
        app.buttons["filter-Favorites"].tap()

        let saved = app.descendants(matching: .any)
            .matching(identifier: "gridPosterCard")
            .firstMatch
        XCTAssertTrue(saved.waitForExistence(timeout: 10), "Favorited \(title) never reached the Library")
    }

    func testRemovingAFavoriteEmptiesTheLibrary() {
        launchPastOnboarding()
        openFirstMovie()

        app.buttons["favoriteButton"].tap()
        app.buttons["favoriteButton"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.tabBars.buttons["Library"].tap()
        app.buttons["filter-Favorites"].tap()

        let card = app.descendants(matching: .any)
            .matching(identifier: "gridPosterCard")
            .firstMatch
        XCTAssertFalse(card.waitForExistence(timeout: 3), "Unfavoriting left the record behind")
    }

    func testLibraryFiltersAreReachable() {
        launchPastOnboarding()
        app.tabBars.buttons["Library"].tap()

        XCTAssertTrue(app.buttons["filter-Favorites"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["filter-Watched"].exists)
        XCTAssertTrue(app.buttons["filter-Watchlist"].exists)

        app.buttons["filter-Watchlist"].tap()
        app.buttons["filter-Watched"].tap()
    }
}
