import SwiftUI

struct MovieCarouselRow: View {
    let title: String
    let movies: [Movie]
    var feed: DiscoverFeed? = nil

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                CarouselHeader(title: title, feed: feed)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie) {
                                PosterCard(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
