import SwiftUI
import SwiftData

struct DiscoverView: View {
    @State private var viewModel = DiscoverViewModel()
    @State private var searchVM = SearchViewModel()
    @Query(sort: \TrackedMovie.addedAt, order: .reverse) private var tracked: [TrackedMovie]

    private let grid = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    private var isSearching: Bool {
        !searchVM.query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var forYouSeed: TrackedMovie? {
        tracked.first { $0.isFavorite } ?? tracked.first { $0.isWatched } ?? tracked.first
    }

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(movie: movie)
                }
                .toolbar(.hidden, for: .navigationBar)
                .task {
                    if viewModel.isEmpty { await viewModel.load() }
                }
                .task(id: searchVM.query) {
                    try? await Task.sleep(for: .milliseconds(350))
                    await searchVM.search()
                }
                .task(id: forYouSeed?.id) {
                    if let seed = forYouSeed {
                        await viewModel.loadForYou(seedId: seed.id)
                    } else {
                        viewModel.forYou = []
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let error = viewModel.errorMessage, viewModel.isEmpty {
            ContentUnavailableView {
                Label("Can't load movies", systemImage: "film.stack")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") { Task { await viewModel.load() } }
                    .buttonStyle(.borderedProminent)
            }
        } else if viewModel.isEmpty && viewModel.isLoading {
            ProgressView("Loading movies…")
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Discover")
                            .font(.largeTitle.bold())
                        InlineSearchBar(text: $searchVM.query)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    if isSearching {
                        searchResults
                    } else {
                        MovieCarouselRow(title: "Trending This Week", movies: viewModel.trending)
                        MovieCarouselRow(title: "For You", movies: viewModel.forYou)
                        MovieCarouselRow(title: "Popular", movies: viewModel.popular)
                        MovieCarouselRow(title: "Top Rated", movies: viewModel.topRated)
                        MovieCarouselRow(title: "Upcoming", movies: viewModel.upcoming)
                    }
                }
                .padding(.bottom)
            }
            .refreshable { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if searchVM.isSearching && searchVM.results.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        } else if searchVM.results.isEmpty && searchVM.hasSearched {
            ContentUnavailableView.search(text: searchVM.query)
        } else {
            LazyVGrid(columns: grid, spacing: 18) {
                ForEach(searchVM.results) { movie in
                    NavigationLink(value: movie) {
                        GridPosterCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
