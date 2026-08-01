import Foundation

struct WidgetFeedItem: Codable {
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let isTV: Bool
}

enum WidgetFeed {
    static let appGroup = "group.com.ksultanov.cinemate"

    static func items(_ key: String) -> [WidgetFeedItem] {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([WidgetFeedItem].self, from: data)) ?? []
    }

    static func index(_ key: String) -> Int {
        UserDefaults(suiteName: appGroup)?.integer(forKey: key) ?? 0
    }

    static func setIndex(_ value: Int, _ key: String) {
        UserDefaults(suiteName: appGroup)?.set(value, forKey: key)
    }
}
