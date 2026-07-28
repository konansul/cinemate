import Foundation

struct BelongsToCollection: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let posterPath: String?
    let backdropPath: String?
}

struct MovieCollection: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let parts: [Movie]
}
