import Foundation

enum AppAnalytics {
    static func screen(_ name: String) {}

    static func openMovie(id: Int, title: String) {}

    static func openShow(id: Int, name: String) {}

    static func trackAction(_ action: String, id: Int, mediaType: String) {}

    static func search(_ query: String) {}
}
