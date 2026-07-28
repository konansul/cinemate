import SwiftUI

struct GenreMoviesView: View {
    let genre: Genre
    @State private var viewModel = GenreMoviesViewModel()
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
                ContentUnavailableView {
                    Label("Can't load movies", systemImage: "film.stack")
                } description: {
                    Text(error)
                }
                .padding(.top, 60)
            } else if viewModel.movies.isEmpty && viewModel.isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(value: movie) {
                            GridPosterCard(movie: movie)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if movie.id == viewModel.movies.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView().padding(.vertical, 16)
                }
            }
        }
        .navigationTitle(genre.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.start(genreId: genre.id) }
    }
}
