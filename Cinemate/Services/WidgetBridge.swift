import Foundation
import WidgetKit

struct WidgetFeedItem: Codable {
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let isTV: Bool
}

enum WidgetBridge {
    static let appGroup = "group.com.ksultanov.cinemate"

    static func saveTrending(_ items: [WidgetFeedItem]) {
        write(items, key: "trending")
    }

    static func saveForYou(_ items: [WidgetFeedItem]) {
        write(items, key: "forYou")
    }

    private static func write(_ items: [WidgetFeedItem], key: String) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
