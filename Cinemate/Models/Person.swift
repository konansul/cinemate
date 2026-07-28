import Foundation

struct Person: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let profilePath: String?
    let knownForDepartment: String?
    let movieCredits: PersonCredits?
}

struct PersonCredits: Codable, Hashable {
    let cast: [PersonCredit]
}

struct PersonCredit: Codable, Hashable, Identifiable {
    let id: Int
    let title: String?
    let character: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let popularity: Double?
}

extension Person {
    var bornText: String? {
        var parts: [String] = []
        if let formatted = Person.displayDate(birthday) { parts.append(formatted) }
        if let place = placeOfBirth, !place.isEmpty { parts.append(place) }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    static func displayDate(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")
        guard let date = parser.date(from: raw) else { return nil }
        let display = DateFormatter()
        display.dateStyle = .long
        return display.string(from: date)
    }
}

extension PersonCredit {
    var year: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "" }
        return String(releaseDate.prefix(4))
    }

    var asMovie: Movie {
        Movie(
            id: id,
            title: title ?? "",
            overview: nil,
            posterPath: posterPath,
            backdropPath: nil,
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
