import Foundation
import Testing
@testable import Cinemate

@Suite("Media item decoding")
struct MediaItemTests {
    private func raw(_ json: String) throws -> RawMediaItem {
        try Fixture.tmdbDecoder.decode(RawMediaItem.self, from: Data(json.utf8))
    }

    @Test func mapsMovieEntries() throws {
        let item = try #require(raw(#"{"id":550,"media_type":"movie","title":"Fight Club"}"#).asMediaItem)

        #expect(item.id == "movie-550")
        #expect(item.isTV == false)
        #expect(item.movie?.title == "Fight Club")
        #expect(item.show == nil)
    }

    @Test func mapsShowEntries() throws {
        let item = try #require(raw(#"{"id":1399,"media_type":"tv","name":"Game of Thrones"}"#).asMediaItem)

        #expect(item.id == "tv-1399")
        #expect(item.isTV)
        #expect(item.show?.name == "Game of Thrones")
        #expect(item.movie == nil)
    }

    @Test func dropsEntriesThatAreNeitherMovieNorShow() throws {
        #expect(try raw(#"{"id":1,"media_type":"person","name":"Brad Pitt"}"#).asMediaItem == nil)
        #expect(try raw(#"{"id":2,"title":"No media type"}"#).asMediaItem == nil)
    }

    @Test func aMovieAndAShowSharingAnIdStayDistinct() throws {
        let movie = try #require(raw(#"{"id":42,"media_type":"movie","title":"A"}"#).asMediaItem)
        let show = try #require(raw(#"{"id":42,"media_type":"tv","name":"B"}"#).asMediaItem)

        #expect(movie.id != show.id)
    }

    @Test func decodesAPagedListAndConvertsSnakeCaseKeys() throws {
        let json = """
        {
          "page": 2,
          "total_pages": 7,
          "results": [
            {"id":550,"media_type":"movie","title":"Fight Club","poster_path":"/a.jpg","release_date":"1999-10-15"},
            {"id":1399,"media_type":"tv","name":"Game of Thrones","first_air_date":"2011-04-17"}
          ]
        }
        """

        let response = try Fixture.tmdbDecoder.decode(MediaListResponse.self, from: Data(json.utf8))

        #expect(response.page == 2)
        #expect(response.totalPages == 7)
        #expect(response.results.count == 2)
        #expect(response.results[0].posterPath == "/a.jpg")
        #expect(response.results[0].releaseDate == "1999-10-15")
        #expect(response.results[1].firstAirDate == "2011-04-17")
        #expect(response.results.compactMap(\.asMediaItem).count == 2)
    }
}
