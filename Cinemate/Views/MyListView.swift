import SwiftUI
import SwiftData

enum LibraryFilter: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case watched = "Watched"
    case watchlist = "Watchlist"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .watchlist: return "bookmark.fill"
        case .watched:   return "checkmark.circle.fill"
        case .favorites: return "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .watchlist: return .blue
        case .watched:   return .green
        case .favorites: return .red
        }
    }
}

enum LibrarySort: String, CaseIterable, Identifiable {
    case dateAdded = "Date added"
    case rating = "Your rating"
    case title = "Title"
    var id: String { rawValue }
}

struct MyListView: View {
    @Query(sort: \TrackedMovie.addedAt, order: .reverse) private var tracked: [TrackedMovie]
    @State private var filter: LibraryFilter = .favorites
    @State private var sort: LibrarySort = .dateAdded
    @State private var showSettings = false
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    private func movies(for filter: LibraryFilter) -> [TrackedMovie] {
        switch filter {
        case .watchlist: return tracked.filter { $0.inWatchlist }
        case .watched:   return tracked.filter { $0.isWatched }
        case .favorites: return tracked.filter { $0.isFavorite }
        }
    }

    private var shown: [TrackedMovie] {
        let filtered = movies(for: filter)
        switch sort {
        case .dateAdded: return filtered.sorted { $0.addedAt > $1.addedAt }
        case .rating:    return filtered.sorted { $0.userRating > $1.userRating }
        case .title:     return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    filterCards
                    grid
                }
                .padding(.bottom)
            }
            .sensoryFeedback(.selection, trigger: filter)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
            .navigationDestination(for: CastMember.self) { PersonDetailView(castMember: $0) }
            .navigationDestination(for: Genre.self) { GenreMoviesView(genre: $0) }
            .navigationDestination(for: BelongsToCollection.self) { CollectionView(collection: $0) }
            .navigationDestination(for: TVShow.self) { TVDetailView(show: $0) }
            .navigationDestination(for: CastListRoute.self) { CastListView(movie: $0.movie, cast: $0.cast) }
            .navigationDestination(for: ReviewsRoute.self) { ReviewsView(movie: $0.movie, reviews: $0.reviews) }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .task {
                let items = tracked
                    .filter { $0.inWatchlist }
                    .map { (id: $0.id, title: $0.title, releaseDate: $0.releaseDate) }
                await NotificationManager.shared.syncReleaseReminders(for: items)
            }
            .onAppear { AppAnalytics.screen("Library") }
        }
    }

    @ViewBuilder
    private var grid: some View {
        if shown.isEmpty {
            ContentUnavailableView(
                emptyTitle,
                systemImage: filter.icon,
                description: Text(emptyMessage)
            )
            .frame(maxWidth: .infinity, minHeight: 320)
        } else {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(shown) { item in
                    if item.isTV {
                        NavigationLink(value: item.asShow) {
                            GridPosterCard(movie: item.asShow.asMovie)
                        }
                        .buttonStyle(.plain)
                    } else {
                        NavigationLink(value: item.asMovie) {
                            GridPosterCard(movie: item.asMovie)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Text("Library").font(.largeTitle.bold())
            Spacer()
            Menu {
                Picker("Sort", selection: $sort) {
                    ForEach(LibrarySort.allCases) { Text($0.rawValue).tag($0) }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down").font(.title3)
            }
            .tint(.primary)
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape").font(.title3)
            }
            .tint(.primary)
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var filterCards: some View {
        HStack(spacing: 10) {
            ForEach(LibraryFilter.allCases) { option in
                filterCard(option)
            }
        }
        .padding(.horizontal)
    }

    private func filterCard(_ option: LibraryFilter) -> some View {
        let active = (filter == option)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { filter = option }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: option.icon).font(.subheadline)
                Text("\(movies(for: option).count)").font(.title3.bold())
                Text(option.rawValue).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(active ? option.color : .primary)
            .background(active ? option.color.opacity(0.18) : Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var emptyTitle: String {
        switch filter {
        case .watchlist: return "Watchlist is empty"
        case .watched:   return "Nothing watched yet"
        case .favorites: return "No favorites yet"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .watchlist: return "Add movies you want to see from any detail screen."
        case .watched:   return "Mark movies as watched to build your history."
        case .favorites: return "Tap the heart on a movie to keep it here."
        }
    }
}
