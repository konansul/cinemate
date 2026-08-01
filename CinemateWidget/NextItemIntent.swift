import AppIntents
import WidgetKit

struct NextItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Next"

    @Parameter(title: "Feed")
    var feed: String

    init() {}

    init(feed: String) {
        self.feed = feed
    }

    func perform() async throws -> some IntentResult {
        let items = WidgetFeed.items(feed)
        guard !items.isEmpty else { return .result() }
        let indexKey = feed + "Index"
        let current = WidgetFeed.index(indexKey)
        WidgetFeed.setIndex((current + 1) % items.count, indexKey)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
