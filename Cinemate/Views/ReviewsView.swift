import SwiftUI

struct ReviewsView: View {
    let movie: Movie
    let reviews: [Review]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MovieHeaderCard(
                    movie: movie,
                    subtitle: "\(reviews.count) review\(reviews.count == 1 ? "" : "s")"
                )

                if reviews.isEmpty {
                    ContentUnavailableView(
                        "No reviews yet",
                        systemImage: "text.bubble",
                        description: Text("No one has reviewed this movie on TMDB.")
                    )
                    .padding(.top, 40)
                } else {
                    ForEach(reviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
    }
}
