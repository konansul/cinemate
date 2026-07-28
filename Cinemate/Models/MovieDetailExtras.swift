import Foundation

struct Credits: Codable, Hashable {
    let cast: [CastMember]
}

struct CastMember: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
}

struct Videos: Codable, Hashable {
    let results: [Video]
}

struct Video: Codable, Hashable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool?
}
