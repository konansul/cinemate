import SwiftUI

struct MixedCarouselRow: View {
    let title: String
    let items: [MediaItem]
    var feed: DiscoverFeed? = nil

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                CarouselHeader(title: title, feed: feed)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(items) { item in
                            if let show = item.show {
                                NavigationLink(value: show) {
                                    PosterCard(movie: show.asMovie)
                                }
                                .buttonStyle(HapticButtonStyle())
                                .accessibilityIdentifier("posterCard")
                            } else if let movie = item.movie {
                                NavigationLink(value: movie) {
                                    PosterCard(movie: movie)
                                }
                                .buttonStyle(HapticButtonStyle())
                                .accessibilityIdentifier("posterCard")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
