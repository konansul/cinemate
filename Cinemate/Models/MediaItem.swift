import Foundation

struct MediaItem: Identifiable, Hashable {
    let movie: Movie?
    let show: TVShow?

    init(movie: Movie) {
        self.movie = movie
        self.show = nil
    }

    init(show: TVShow) {
        self.movie = nil
        self.show = show
    }

    var id: String {
        if let movie { return "movie-\(movie.id)" }
        if let show { return "tv-\(show.id)" }
        return "unknown"
    }

    var isTV: Bool { show != nil }

    var poster: Movie { movie ?? show?.asMovie ?? Movie.placeholder }
}

struct MediaListResponse: Decodable {
    let results: [RawMediaItem]
    let page: Int?
    let totalPages: Int?
}

struct RawMediaItem: Decodable {
    let id: Int
    let mediaType: String?
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let voteAverage: Double?

    var asMediaItem: MediaItem? {
        switch mediaType {
        case "movie":
            return MediaItem(movie: Movie(
                id: id, title: title ?? "", overview: overview,
                posterPath: posterPath, backdropPath: backdropPath,
                releaseDate: releaseDate, voteAverage: voteAverage,
                runtime: nil, genres: nil, tagline: nil,
                credits: nil, videos: nil, belongsToCollection: nil
            ))
        case "tv":
            return MediaItem(show: TVShow(
                id: id, name: name ?? "", overview: overview,
                posterPath: posterPath, backdropPath: backdropPath,
                firstAirDate: firstAirDate, voteAverage: voteAverage,
                numberOfSeasons: nil, numberOfEpisodes: nil, episodeRunTime: nil,
                genres: nil, tagline: nil, seasons: nil, credits: nil, videos: nil
            ))
        default:
            return nil
        }
    }
}

extension Movie {
    static let placeholder = Movie(
        id: 0, title: "", overview: nil, posterPath: nil, backdropPath: nil,
        releaseDate: nil, voteAverage: nil, runtime: nil, genres: nil,
        tagline: nil, credits: nil, videos: nil, belongsToCollection: nil
    )
}
