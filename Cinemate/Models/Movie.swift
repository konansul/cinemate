import Foundation

struct Movie: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?

    let runtime: Int?
    let genres: [Genre]?
    let tagline: String?
    let credits: Credits?
    let videos: Videos?
}

struct Genre: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
}

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}

extension Movie {
    var year: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "" }
        return String(releaseDate.prefix(4))
    }

    var ratingText: String {
        guard let voteAverage, voteAverage > 0 else { return "—" }
        return String(format: "%.1f", voteAverage)
    }

    var runtimeText: String? {
        guard let runtime, runtime > 0 else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    var genreNames: String {
        (genres ?? []).map(\.name).joined(separator: " · ")
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
}
