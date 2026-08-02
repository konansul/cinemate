import Testing
@testable import Cinemate

@Suite("Tracked records")
struct TrackedMovieTests {
    @Test func aFreshRecordCountsAsEmpty() {
        let record = TrackedMovie(movie: Fixture.movie(id: 1))

        #expect(record.isEmpty)
        #expect(record.isTV == false)
        #expect(record.mediaType == "movie")
    }

    @Test(arguments: ["favorite", "watched", "watchlist", "rating", "note"])
    func anyTrackedStateMakesItNonEmpty(_ kind: String) {
        let record = TrackedMovie(movie: Fixture.movie(id: 1))

        switch kind {
        case "favorite":  record.isFavorite = true
        case "watched":   record.isWatched = true
        case "watchlist": record.inWatchlist = true
        case "rating":    record.userRating = 4
        default:          record.note = "Loved it"
        }

        #expect(record.isEmpty == false)
    }

    @Test func showsAreStoredWithTheTVMediaType() {
        let record = TrackedMovie(show: Fixture.show(id: 1399, name: "Game of Thrones"))

        #expect(record.isTV)
        #expect(record.mediaType == "tv")
        #expect(record.title == "Game of Thrones")
    }

    @Test func convertingBackToAMovieKeepsIdentity() {
        let record = TrackedMovie(movie: Fixture.movie(id: 550, title: "Fight Club"))
        let movie = record.asMovie

        #expect(movie.id == 550)
        #expect(movie.title == "Fight Club")
    }
}
