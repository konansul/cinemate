import Foundation

struct NewsItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let link: URL
    let source: String
    let date: Date?
    let imageURL: URL?
}
