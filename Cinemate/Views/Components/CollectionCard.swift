import SwiftUI

struct CollectionCard: View {
    let collection: MovieCollection
    var width: CGFloat? = nil
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var cardWidth: CGFloat {
        width ?? (sizeClass == .regular ? 168 : 120)
    }

    private var displayName: String {
        collection.name.replacingOccurrences(of: " Collection", with: "")
    }

    private var navValue: BelongsToCollection {
        BelongsToCollection(
            id: collection.id,
            name: collection.name,
            posterPath: collection.posterPath,
            backdropPath: collection.backdropPath
        )
    }

    var body: some View {
        NavigationLink(value: navValue) {
            VStack(alignment: .leading, spacing: 6) {
                poster
                    .frame(width: cardWidth, height: cardWidth * 1.5)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.caption2)
                            .padding(6)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(6)
                    }

                Text(displayName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text("\(collection.parts.count) movies")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: cardWidth, alignment: .leading)
        }
        .buttonStyle(HapticButtonStyle())
    }

    @ViewBuilder
    private var poster: some View {
        AsyncImage(url: TMDBConfig.posterURL(collection.posterPath)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .empty:
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    ProgressView()
                }
            case .failure:
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    Image(systemName: "square.stack")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            @unknown default:
                Rectangle().fill(Color.gray.opacity(0.25))
            }
        }
    }
}
