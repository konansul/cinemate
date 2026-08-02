import Foundation
@testable import Cinemate

enum Fixture {
    static func movie(id: Int, title: String = "Movie", releaseDate: String? = nil) -> Movie {
        Movie(
            id: id, title: title, overview: nil, posterPath: nil, backdropPath: nil,
            releaseDate: releaseDate, voteAverage: nil, runtime: nil, genres: nil,
            tagline: nil, credits: nil, videos: nil, belongsToCollection: nil
        )
    }

    static func show(id: Int, name: String = "Show") -> TVShow {
        TVShow(
            id: id, name: name, overview: nil, posterPath: nil, backdropPath: nil,
            firstAirDate: nil, voteAverage: nil, numberOfSeasons: nil,
            numberOfEpisodes: nil, episodeRunTime: nil, genres: nil,
            tagline: nil, seasons: nil, credits: nil, videos: nil
        )
    }

    static var tmdbDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
