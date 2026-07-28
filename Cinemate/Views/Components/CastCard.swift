import SwiftUI

struct CastCard: View {
    let member: CastMember

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: TMDBConfig.profileURL(member.profilePath)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.2))
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 84, height: 126)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(member.name)
                .font(.caption)
                .lineLimit(1)

            if let character = member.character, !character.isEmpty {
                Text(character)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 84)
    }
}
