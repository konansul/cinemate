import SwiftUI

struct MovieHeaderCard: View {
    let movie: Movie
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: TMDBConfig.posterURL(movie.posterPath, size: "w185")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 70, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.title3.bold())
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text(movie.ratingText)
                    if !movie.year.isEmpty {
                        Text("· \(movie.year)").foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }
}
