import Foundation

struct TVShow: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let firstAirDate: String?
    let voteAverage: Double?

    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let episodeRunTime: [Int]?
    let genres: [Genre]?
    let tagline: String?
    let seasons: [Season]?
    let credits: Credits?
    let videos: Videos?
}

struct TVResponse: Codable {
    let page: Int
    let results: [TVShow]
    let totalPages: Int
    let totalResults: Int
}

struct Season: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let seasonNumber: Int
    let episodeCount: Int?
    let posterPath: String?
    let airDate: String?
    let overview: String?
}

struct SeasonDetail: Codable, Hashable {
    let id: Int
    let name: String?
    let seasonNumber: Int?
    let overview: String?
    let posterPath: String?
    let airDate: String?
    let episodes: [Episode]
}

struct Episode: Codable, Hashable, Identifiable {
    let id: Int
    let name: String?
    let episodeNumber: Int
    let overview: String?
    let stillPath: String?
    let airDate: String?
    let runtime: Int?
    let voteAverage: Double?
}

extension TVShow {
    var year: String {
        guard let firstAirDate, firstAirDate.count >= 4 else { return "" }
        return String(firstAirDate.prefix(4))
    }

    var ratingText: String {
        guard let voteAverage, voteAverage > 0 else { return "—" }
        return String(format: "%.1f", voteAverage)
    }

    var seasonsText: String? {
        guard let numberOfSeasons, numberOfSeasons > 0 else { return nil }
        return numberOfSeasons == 1 ? "1 Season" : "\(numberOfSeasons) Seasons"
    }

    var runtimeText: String? {
        guard let minutes = episodeRunTime?.first, minutes > 0 else { return nil }
        return "\(minutes)m / ep"
    }

    var trailerURL: URL? {
        let youTube: [Video] = (videos?.results ?? []).filter { $0.site == "YouTube" }
        var chosen: Video? = youTube.first { $0.type == "Trailer" && ($0.official ?? false) }
        if chosen == nil { chosen = youTube.first { $0.type == "Trailer" } }
        if chosen == nil { chosen = youTube.first }
        guard let key = chosen?.key else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    var topCast: [CastMember] {
        Array((credits?.cast ?? []).prefix(12))
    }

    var displayableSeasons: [Season] {
        (seasons ?? []).filter { $0.seasonNumber > 0 }
    }

    var asMovie: Movie {
        Movie(
            id: id,
            title: name,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: firstAirDate,
            voteAverage: voteAverage,
            runtime: nil,
            genres: genres,
            tagline: tagline,
            credits: credits,
            videos: videos,
            belongsToCollection: nil
        )
    }
}

extension Episode {
    var airYearText: String {
        guard let airDate, airDate.count >= 4 else { return "" }
        return String(airDate.prefix(4))
    }

    var runtimeText: String? {
        guard let runtime, runtime > 0 else { return nil }
        return "\(runtime)m"
    }
}
