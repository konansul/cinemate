import WidgetKit
import SwiftUI
import AppIntents

struct FeedEntry: TimelineEntry {
    let date: Date
    let label: String
    let title: String
    let isTV: Bool
    let poster: Image?
    let backdrop: Image?
    let feedKey: String
    let isEmpty: Bool
}

struct FeedProvider: TimelineProvider {
    let feedKey: String
    let label: String

    func placeholder(in context: Context) -> FeedEntry {
        FeedEntry(date: Date(), label: label, title: "Cinemate", isTV: false, poster: nil, backdrop: nil, feedKey: feedKey, isEmpty: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (FeedEntry) -> Void) {
        Task {
            completion(await makeEntry(at: WidgetFeed.index(feedKey + "Index"), date: Date(), family: context.family))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FeedEntry>) -> Void) {
        Task {
            let items = WidgetFeed.items(feedKey)
            let now = Date()
            if items.isEmpty {
                let empty = FeedEntry(date: now, label: label, title: "Open Cinemate", isTV: false, poster: nil, backdrop: nil, feedKey: feedKey, isEmpty: true)
                completion(Timeline(entries: [empty], policy: .after(now.addingTimeInterval(1800))))
                return
            }
            let base = WidgetFeed.index(feedKey + "Index")
            var entries: [FeedEntry] = []
            let steps = min(items.count, 5)
            for offset in 0..<steps {
                let date = Calendar.current.date(byAdding: .minute, value: offset * 30, to: now) ?? now
                entries.append(await makeEntry(at: base + offset, date: date, family: context.family))
            }
            let refresh = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now
            completion(Timeline(entries: entries, policy: .after(refresh)))
        }
    }

    private func makeEntry(at rawIndex: Int, date: Date, family: WidgetFamily) async -> FeedEntry {
        let items = WidgetFeed.items(feedKey)
        guard !items.isEmpty else {
            return FeedEntry(date: date, label: label, title: "Open Cinemate", isTV: false, poster: nil, backdrop: nil, feedKey: feedKey, isEmpty: true)
        }
        let wrapped = ((rawIndex % items.count) + items.count) % items.count
        let item = items[wrapped]
        let poster = await WidgetImage.poster(item.posterPath)
        let backdrop = family == .systemMedium ? await WidgetImage.backdrop(item.backdropPath) : nil
        return FeedEntry(date: date, label: label, title: item.title, isTV: item.isTV, poster: poster, backdrop: backdrop, feedKey: feedKey, isEmpty: false)
    }
}

struct FeedEntryView: View {
    var entry: FeedEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if family == .systemMedium {
                mediumContent
            } else {
                smallContent
            }
        }
        .overlay(alignment: .topTrailing) {
            if !entry.isEmpty {
                nextButton.padding(8)
            }
        }
        .containerBackground(for: .widget) { background }
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Spacer(minLength: 0)
            Text(entry.label.uppercased())
                .font(.caption2.bold())
                .foregroundStyle(.white.opacity(0.85))
            Text(entry.title)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumContent: some View {
        HStack(spacing: 14) {
            posterImage
                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Label(entry.label.uppercased(), systemImage: entry.feedKey == "forYou" ? "sparkles" : "flame.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(entry.feedKey == "forYou" ? .purple : .orange)
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(3)
                if !entry.isEmpty {
                    Text(entry.isTV ? "TV Show" : "Movie")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var background: some View {
        if family == .systemMedium {
            ZStack {
                if let backdrop = entry.backdrop {
                    backdrop.resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
                }
                Color.black.opacity(0.72)
            }
        } else {
            ZStack {
                posterImage.scaledToFill()
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.3),
                        .init(color: .black.opacity(0.55), location: 0.62),
                        .init(color: .black.opacity(0.92), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
    }

    private var nextButton: some View {
        Button(intent: NextItemIntent(feed: entry.feedKey)) {
            Image(systemName: "forward.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(7)
                .background(.black.opacity(0.4), in: Circle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var posterImage: some View {
        if let poster = entry.poster {
            poster.resizable()
        } else {
            LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct CinemateTrendingWidget: Widget {
    let kind = "CinemateTrendingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FeedProvider(feedKey: "trending", label: "Trending")) { entry in
            FeedEntryView(entry: entry)
        }
        .configurationDisplayName("Trending")
        .description("Trending movies and shows. Tap to flip.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CinemateForYouWidget: Widget {
    let kind = "CinemateForYouWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FeedProvider(feedKey: "forYou", label: "For You")) { entry in
            FeedEntryView(entry: entry)
        }
        .configurationDisplayName("For You")
        .description("Picks based on your taste. Tap to flip.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
