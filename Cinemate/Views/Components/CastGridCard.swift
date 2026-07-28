import SwiftUI

struct CastGridCard: View {
    let member: CastMember

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: TMDBConfig.profileURL(member.profilePath)) { image in
                image.resizable()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.2))
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(member.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            if let character = member.character, !character.isEmpty {
                Text(character)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
