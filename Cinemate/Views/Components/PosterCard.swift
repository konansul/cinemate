import SwiftUI

struct PosterCard: View {
    let movie: Movie
    var width: CGFloat = 120
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var cardWidth: CGFloat {
        sizeClass == .regular ? 168 : width
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            poster
                .frame(width: cardWidth, height: cardWidth * 1.5)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(movie.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.primary)

            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(movie.ratingText)
                    .foregroundStyle(.secondary)
                if !movie.year.isEmpty {
                    Text("· \(movie.year)")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption2)
        }
        .frame(width: cardWidth, alignment: .leading)
    }

    @ViewBuilder
    private var poster: some View {
        AsyncImage(url: TMDBConfig.posterURL(movie.posterPath)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .empty:
                ZStack {
                    placeholder
                    ProgressView()
                }
            case .failure:
                ZStack {
                    placeholder
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            @unknown default:
                placeholder
            }
        }
    }

    private var placeholder: some View {
        Rectangle().fill(Color.gray.opacity(0.25))
    }
}
