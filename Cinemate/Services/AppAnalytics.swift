import Foundation
import FirebaseAnalytics

enum AppAnalytics {
    static func screen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }

    static func openMovie(id: Int, title: String) {
        Analytics.logEvent("open_movie", parameters: [
            "movie_id": id,
            "title": title
        ])
    }

    static func openShow(id: Int, name: String) {
        Analytics.logEvent("open_show", parameters: [
            "show_id": id,
            "name": name
        ])
    }

    static func trackAction(_ action: String, id: Int, mediaType: String) {
        Analytics.logEvent("track_action", parameters: [
            "action": action,
            "item_id": id,
            "media_type": mediaType
        ])
    }

    static func search(_ query: String) {
        Analytics.logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: query
        ])
    }
}
