import SwiftUI
import SwiftData

struct DiscoverView: View {
    @State private var viewModel = DiscoverViewModel()
    @State private var searchVM = SearchViewModel()
    @Query(sort: \TrackedMovie.addedAt, order: .reverse) private var tracked: [TrackedMovie]

    private let grid = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    private var isSearching: Bool {
        !searchVM.query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var forYouSeed: TrackedMovie? {
        tracked.first { $0.isFavorite } ?? tracked.first { $0.isWatched } ?? tracked.first
    }

    private var forYouFeed: DiscoverFeed? {
        viewModel.forYouSeedId.map { .forYou(seedId: $0) }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(movie: movie)
                }
                .navigationDestination(for: CastMember.self) { member in
                    PersonDetailView(castMember: member)
                }
                .navigationDestination(for: Genre.self) { genre in
                    GenreMoviesView(genre: genre)
                }
                .navigationDestination(for: BelongsToCollection.self) { collection in
                    CollectionView(collection: collection)
                }
                .navigationDestination(for: TVShow.self) { show in
                    TVDetailView(show: show)
                }
                .navigationDestination(for: CastListRoute.self) { route in
                    CastListView(movie: route.movie, cast: route.cast)
                }
                .navigationDestination(for: ReviewsRoute.self) { route in
                    ReviewsView(movie: route.movie, reviews: route.reviews)
                }
                .navigationDestination(for: DiscoverFeed.self) { feed in
                    FeedGridView(feed: feed)
                }
                .navigationDestination(for: FranchisesRoute.self) { route in
                    FranchiseGridView(collections: route.collections)
                }
                .toolbar(.hidden, for: .navigationBar)
                .task {
                    if viewModel.isEmpty { await viewModel.load() }
                    await viewModel.refreshForYou(trackedSeed: forYouSeed?.id)
                }
                .task {
                    await viewModel.loadFranchises()
                }
                .task(id: searchVM.query) {
                    try? await Task.sleep(for: .milliseconds(350))
                    await searchVM.search()
                }
                .task(id: forYouSeed?.id) {
                    await viewModel.refreshForYou(trackedSeed: forYouSeed?.id)
                }
                .onAppear { AppAnalytics.screen("Discover") }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let error = viewModel.errorMessage, viewModel.isEmpty {
            ContentUnavailableView {
                Label("Can't load", systemImage: "film.stack")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") { Task { await viewModel.load() } }
                    .buttonStyle(.borderedProminent)
            }
        } else if viewModel.isEmpty && viewModel.isLoading {
            ProgressView("Loading…")
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
                        genreRow
                        MixedCarouselRow(title: "Trending This Week", items: viewModel.trendingMixed, feed: .trending)
                        MovieCarouselRow(title: "For You", movies: viewModel.forYou, feed: forYouFeed)
                        MixedCarouselRow(title: "Popular", items: viewModel.popularMixed, feed: .popular)
                        franchisesRow
                        ShowCarouselRow(title: "TV Shows", shows: viewModel.tvShows, feed: .tvShows)
                        MovieCarouselRow(title: "Top Rated", movies: viewModel.topRated, feed: .topRated)
                        MovieCarouselRow(title: "Upcoming", movies: viewModel.upcoming, feed: .upcoming)
                    }
                }
                .padding(.bottom)
            }
            .refreshable { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var franchisesRow: some View {
        if !viewModel.franchises.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Franchises")
                        .font(.title2.bold())
                    Spacer()
                    NavigationLink(value: FranchisesRoute(collections: viewModel.franchises)) {
                        Text("See all")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(viewModel.franchises) { collection in
                            CollectionCard(collection: collection)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var genreRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GenreCatalog.all) { genre in
                    NavigationLink(value: genre) {
                        Text(genre.name)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
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
                ForEach(searchVM.results) { item in
                    if let show = item.show {
                        NavigationLink(value: show) {
                            GridPosterCard(movie: show.asMovie)
                        }
                        .buttonStyle(.plain)
                    } else if let movie = item.movie {
                        NavigationLink(value: movie) {
                            GridPosterCard(movie: movie)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
