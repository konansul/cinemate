import Foundation

struct ReviewResponse: Codable {
    let results: [Review]
}

struct Review: Codable, Identifiable, Hashable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?
    let authorDetails: AuthorDetails?
}

struct AuthorDetails: Codable, Hashable {
    let rating: Double?
    let avatarPath: String?
}

extension Review {
    var ratingText: String? {
        guard let rating = authorDetails?.rating, rating > 0 else { return nil }
        return String(format: "%.0f/10", rating)
    }

    var dateText: String? {
        guard let createdAt else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = parser.date(from: createdAt) else {
            return String(createdAt.prefix(10))
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
