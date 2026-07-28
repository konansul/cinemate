import SwiftUI

struct ShowCarouselRow: View {
    let title: String
    let shows: [TVShow]

    var body: some View {
        if !shows.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2.bold())
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(shows) { show in
                            NavigationLink(value: show) {
                                PosterCard(movie: show.asMovie)
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
