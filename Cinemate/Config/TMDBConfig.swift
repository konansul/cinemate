import Foundation

enum TMDBConfig {

    static let apiKey = Secrets.tmdbAPIKey

    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p"

    static var isConfigured: Bool {
        !apiKey.isEmpty && !apiKey.hasPrefix("PASTE_")
    }

    static func posterURL(_ path: String?, size: String = "w500") -> URL? {
        guard let path else { return nil }
        return URL(string: "\(imageBaseURL)/\(size)\(path)")
    }

    static func backdropURL(_ path: String?, size: String = "w780") -> URL? {
        guard let path else { return nil }
        return URL(string: "\(imageBaseURL)/\(size)\(path)")
    }

    static func profileURL(_ path: String?, size: String = "w185") -> URL? {
        guard let path else { return nil }
        return URL(string: "\(imageBaseURL)/\(size)\(path)")
    }

    static func logoURL(_ path: String?, size: String = "w92") -> URL? {
        guard let path else { return nil }
        return URL(string: "\(imageBaseURL)/\(size)\(path)")
    }
}
