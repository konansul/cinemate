import SwiftUI

struct CollectionView: View {
    let collection: BelongsToCollection
    @State private var viewModel: CollectionViewModel
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    init(collection: BelongsToCollection) {
        self.collection = collection
        _viewModel = State(initialValue: CollectionViewModel(collectionId: collection.id))
    }

    private var name: String { viewModel.collection?.name ?? collection.name }
    private var backdropPath: String? { viewModel.collection?.backdropPath ?? collection.backdropPath }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let backdrop = TMDBConfig.backdropURL(backdropPath) {
                    Color.clear
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .overlay {
                            AsyncImage(url: backdrop) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.2))
                            }
                        }
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let overview = viewModel.collection?.overview, !overview.isEmpty {
                    Text(overview).foregroundStyle(.secondary)
                }

                if !viewModel.sortedParts.isEmpty {
                    Text("\(viewModel.sortedParts.count) movies")
                        .font(.headline)

                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(viewModel.sortedParts) { movie in
                            NavigationLink(value: movie) {
                                GridPosterCard(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }
            }
            .padding()
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.load() }
    }
}
