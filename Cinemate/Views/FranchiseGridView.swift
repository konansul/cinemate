import SwiftUI

struct FranchisesRoute: Hashable {
    let collections: [MovieCollection]
}

struct FranchiseGridView: View {
    let collections: [MovieCollection]
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(collections) { collection in
                    CollectionCard(collection: collection, width: 150)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Franchises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
