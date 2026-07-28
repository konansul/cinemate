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
        try await fetchList("/movie/upcoming")
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
