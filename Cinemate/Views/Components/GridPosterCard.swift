import SwiftUI

struct GridPosterCard: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: TMDBConfig.posterURL(movie.posterPath)) { image in
                image.resizable()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(movie.title)
                .font(.subheadline)
                .lineLimit(1)

            HStack(spacing: 3) {
                Image(systemName: "star.fill").foregroundStyle(.yellow)
                Text(movie.ratingText).foregroundStyle(.secondary)
                if !movie.year.isEmpty {
                    Text("· \(movie.year)").foregroundStyle(.secondary)
                }
            }
            .font(.caption2)
        }
    }
}
