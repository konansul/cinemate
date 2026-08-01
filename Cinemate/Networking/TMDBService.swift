import Foundation

enum TMDBError: LocalizedError {
    case missingKey
    case badURL
    case badResponse(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "Add your free TMDB API key in TMDBConfig.swift to load movies."
        case .badURL:
            return "Something went wrong building the request."
        case .badResponse(let code):
            return "The movie service returned an error (\(code)). Try again."
        case .decoding:
            return "Couldn't read the data from the movie service."
        }
    }
}

struct TMDBService {
    static let shared = TMDBService()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    func trending() async throws -> [Movie] {
        try await fetchList("/trending/movie/week")
    }

    func popular() async throws -> [Movie] {
        try await fetchList("/movie/popular")
    }

    func topRated() async throws -> [Movie] {
        try await fetchList("/movie/top_rated")
    }

    func upcoming() async throws -> [Movie] {
        try await fetchList("/discover/movie", query: [
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "primary_release_date.gte", value: Self.todayString()),
            URLQueryItem(name: "include_adult", value: "false")
        ])
    }

    func trendingAll() async throws -> [MediaItem] {
        let response: MediaListResponse = try await get("/trending/all/week")
        return response.results.compactMap { $0.asMediaItem }
    }

    func searchMulti(_ query: String) async throws -> [MediaItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let response: MediaListResponse = try await get("/search/multi", query: [
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "include_adult", value: "false")
        ])
        return response.results.compactMap { $0.asMediaItem }
    }

    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    func search(_ query: String) async throws -> [Movie] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await fetchList("/search/movie", query: [
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "include_adult", value: "false")
        ])
    }

    func details(id: Int) async throws -> Movie {
        try await get("/movie/\(id)", query: [
            URLQueryItem(name: "append_to_response", value: "credits,videos")
        ])
    }

    func recommendations(id: Int) async throws -> [Movie] {
        try await fetchList("/movie/\(id)/recommendations")
    }

    func recommendationsPaged(id: Int, page: Int) async throws -> MovieResponse {
        try await get("/movie/\(id)/recommendations", query: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func person(id: Int) async throws -> Person {
        try await get("/person/\(id)", query: [
            URLQueryItem(name: "append_to_response", value: "movie_credits")
        ])
    }

    func collection(id: Int) async throws -> MovieCollection {
        try await get("/collection/\(id)")
    }

    func discover(genreId: Int, page: Int = 1) async throws -> MovieResponse {
        try await get("/discover/movie", query: [
            URLQueryItem(name: "with_genres", value: String(genreId)),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func trendingAllPaged(page: Int) async throws -> MediaListResponse {
        try await get("/trending/all/week", query: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func popularPaged(page: Int) async throws -> MovieResponse {
        try await get("/movie/popular", query: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func topRatedPaged(page: Int) async throws -> MovieResponse {
        try await get("/movie/top_rated", query: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func upcomingPaged(page: Int) async throws -> MovieResponse {
        try await get("/discover/movie", query: [
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "primary_release_date.gte", value: Self.todayString()),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func trendingTVPaged(page: Int) async throws -> TVResponse {
        try await get("/trending/tv/week", query: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func reviews(id: Int) async throws -> [Review] {
        let response: ReviewResponse = try await get("/movie/\(id)/reviews")
        return response.results
    }

    func watchProviders(id: Int) async throws -> [WatchProvider] {
        let response: WatchProvidersResponse = try await get("/movie/\(id)/watch/providers")
        let region = Locale.current.region?.identifier ?? "US"
        let country = response.results[region]
            ?? response.results["US"]
            ?? response.results.values.first
        return country?.flatrate ?? []
    }

    func trendingTV() async throws -> [TVShow] {
        try await fetchTVList("/trending/tv/week")
    }

    func popularTV() async throws -> [TVShow] {
        try await fetchTVList("/tv/popular")
    }

    func topRatedTV() async throws -> [TVShow] {
        try await fetchTVList("/tv/top_rated")
    }

    func onTheAirTV() async throws -> [TVShow] {
        try await fetchTVList("/tv/on_the_air")
    }

    func searchTV(_ query: String) async throws -> [TVShow] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await fetchTVList("/search/tv", query: [
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "include_adult", value: "false")
        ])
    }

    func tvDetails(id: Int) async throws -> TVShow {
        try await get("/tv/\(id)", query: [
            URLQueryItem(name: "append_to_response", value: "credits,videos")
        ])
    }

    func season(showId: Int, seasonNumber: Int) async throws -> SeasonDetail {
        try await get("/tv/\(showId)/season/\(seasonNumber)")
    }

    func tvReviews(id: Int) async throws -> [Review] {
        let response: ReviewResponse = try await get("/tv/\(id)/reviews")
        return response.results
    }

    func tvWatchProviders(id: Int) async throws -> [WatchProvider] {
        let response: WatchProvidersResponse = try await get("/tv/\(id)/watch/providers")
        let region = Locale.current.region?.identifier ?? "US"
        let country = response.results[region]
            ?? response.results["US"]
            ?? response.results.values.first
        return country?.flatrate ?? []
    }

    private func fetchTVList(_ path: String, query: [URLQueryItem] = []) async throws -> [TVShow] {
        let response: TVResponse = try await get(path, query: query)
        return response.results
    }

    private func fetchList(_ path: String, query: [URLQueryItem] = []) async throws -> [Movie] {
        let response: MovieResponse = try await get(path, query: query)
        return response.results
    }

    private func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        guard TMDBConfig.isConfigured else { throw TMDBError.missingKey }

        var components = URLComponents(string: TMDBConfig.baseURL + path)
        components?.queryItems = [URLQueryItem(name: "api_key", value: TMDBConfig.apiKey)] + query

        guard let url = components?.url else { throw TMDBError.badURL }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else { throw TMDBError.badResponse(-1) }
        guard (200..<300).contains(http.statusCode) else { throw TMDBError.badResponse(http.statusCode) }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw TMDBError.decoding
        }
    }
}
