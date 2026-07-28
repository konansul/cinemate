import SwiftUI

struct CastListView: View {
    let movie: Movie
    let cast: [CastMember]
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 14)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MovieHeaderCard(
                    movie: movie,
                    subtitle: "\(cast.count) cast member\(cast.count == 1 ? "" : "s")"
                )

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(cast) { member in
                        CastGridCard(member: member)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Cast")
        .navigationBarTitleDisplayMode(.inline)
    }
}
