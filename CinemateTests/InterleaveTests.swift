import Testing
@testable import Cinemate

@Suite("Mixed Discover feed")
struct InterleaveTests {
    @Test func alternatesMoviesAndShows() {
        let result = DiscoverViewModel.interleave(
            [Fixture.movie(id: 1), Fixture.movie(id: 2)],
            [Fixture.show(id: 10), Fixture.show(id: 20)]
        )

        #expect(result.map(\.id) == ["movie-1", "tv-10", "movie-2", "tv-20"])
    }

    @Test func keepsTheLongerListWhenCountsDiffer() {
        let result = DiscoverViewModel.interleave(
            [Fixture.movie(id: 1)],
            [Fixture.show(id: 10), Fixture.show(id: 20), Fixture.show(id: 30)]
        )

        #expect(result.map(\.id) == ["movie-1", "tv-10", "tv-20", "tv-30"])
    }

    @Test func handlesEmptyInput() {
        #expect(DiscoverViewModel.interleave([], []).isEmpty)

        let moviesOnly = DiscoverViewModel.interleave([Fixture.movie(id: 1)], [])
        #expect(moviesOnly.map(\.id) == ["movie-1"])

        let showsOnly = DiscoverViewModel.interleave([], [Fixture.show(id: 10)])
        #expect(showsOnly.map(\.id) == ["tv-10"])
    }

    @Test func takesAtMostTwelveOfEachKind() {
        let movies = (1...20).map { Fixture.movie(id: $0) }
        let shows = (1...20).map { Fixture.show(id: 100 + $0) }

        let result = DiscoverViewModel.interleave(movies, shows)

        #expect(result.count == 24)
        #expect(result.filter { !$0.isTV }.count == 12)
        #expect(result.filter(\.isTV).count == 12)
    }
}
