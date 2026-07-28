import Foundation
import SwiftData

@Model
final class TrackedMovie {
    var id: Int = 0
    var title: String = ""
    var overview: String? = nil
    var posterPath: String? = nil
    var backdropPath: String? = nil
    var releaseDate: String? = nil
    var voteAverage: Double? = nil

    var isFavorite: Bool = false
    var isWatched: Bool = false
    var inWatchlist: Bool = false
    var userRating: Int = 0
    var note: String = ""
    var watchedDate: Date? = nil
    var addedAt: Date = Date()

    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.addedAt = Date()
    }

    var isEmpty: Bool {
        !isFavorite && !isWatched && !inWatchlist && userRating == 0 && note.isEmpty
    }
}

extension TrackedMovie {
    var asMovie: Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            runtime: nil,
            genres: nil,
            tagline: nil,
            credits: nil,
            videos: nil,
            belongsToCollection: nil
        )
    }
}
