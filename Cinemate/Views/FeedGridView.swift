import SwiftUI

enum DiscoverFeed: Hashable {
    case trending
    case popular
    case topRated
    case upcoming
    case tvShows
    case forYou(seedId: Int)

    var title: String {
        switch self {
        case .trending: return "Trending This Week"
        case .popular:  return "Popular"
        case .topRated: return "Top Rated"
        case .upcoming: return "Upcoming"
        case .tvShows:  return "TV Shows"
        case .forYou:   return "For You"
        }
    }
}

struct FeedGridView: View {
    let feed: DiscoverFeed
    @State private var viewModel = FeedGridViewModel()
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        ScrollView {
            if let error = viewModel.errorMessage, viewModel.items.isEmpty {
                ContentUnavailableView {
                    Label("Can't load", systemImage: "film.stack")
                } description: {
                    Text(error)
                }
                .padding(.top, 60)
            } else if viewModel.items.isEmpty && viewModel.isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(viewModel.items) { item in
                        posterLink(item)
                            .onAppear {
                                if item.id == viewModel.items.last?.id {
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
        .navigationTitle(feed.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.start(feed: feed) }
    }

    @ViewBuilder
    private func posterLink(_ item: MediaItem) -> some View {
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
