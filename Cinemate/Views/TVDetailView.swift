import SwiftUI
import SwiftData

struct TVDetailView: View {
    @Environment(\.modelContext) private var context
    @Query private var tracked: [TrackedMovie]
    @State private var viewModel: TVDetailViewModel
    @State private var noteText: String = ""
    @State private var selectedSeason: Season?
    @Environment(\.horizontalSizeClass) private var sizeClass

    init(show: TVShow) {
        _viewModel = State(initialValue: TVDetailViewModel(show: show))
    }

    private var show: TVShow { viewModel.show }
    private var record: TrackedMovie? { tracked.first { $0.id == show.id && $0.mediaType == "tv" } }
    private var shareURL: URL? { URL(string: "https://www.themoviedb.org/tv/\(show.id)") }

    var body: some View {
        GeometryReader { geo in
            let wide = sizeClass == .regular
            let posterW = min(380, geo.size.width * 0.4)
            ScrollView {
                if wide {
                    HStack(alignment: .top, spacing: 28) {
                        VStack(alignment: .leading, spacing: 16) {
                            posterHeader
                            metaGenres
                            ratingRow
                            noteEditor
                        }
                        .frame(width: posterW)

                        VStack(alignment: .leading, spacing: 16) {
                            mediaSections
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        posterHeader
                        metaGenres
                        ratingRow
                        noteEditor
                        mediaSections
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(show.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $selectedSeason) { season in
            SeasonView(showId: show.id, showName: show.name, season: season)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let shareURL {
                    ShareLink(item: shareURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .task {
            AppAnalytics.screen("TV Detail")
            AppAnalytics.openShow(id: show.id, name: show.name)
            noteText = record?.note ?? ""
            await viewModel.loadDetails()
        }
    }

    @ViewBuilder
    private var metaGenres: some View {
        metaRow

        if !(show.genres ?? []).isEmpty { genreChips }
    }

    @ViewBuilder
    private var mediaSections: some View {
        if let trailer = show.trailerURL {
            Link(destination: trailer) {
                Label("Play Trailer", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }

        if let backdrop = TMDBConfig.backdropURL(show.backdropPath) {
            backdropSection(backdrop)
        }

        if !viewModel.providers.isEmpty { providersSection }

        if let overview = show.overview, !overview.isEmpty {
            sectionTitle("Overview")
            Text(overview).foregroundStyle(.secondary)
        }

        if !show.displayableSeasons.isEmpty { seasonsSection }

        if !show.topCast.isEmpty { castSection }

        if !viewModel.reviews.isEmpty { reviewsSection }
    }

    private var posterHeader: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: TMDBConfig.posterURL(show.posterPath)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    Image(systemName: "tv").font(.largeTitle).foregroundStyle(.secondary)
                }
            }

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.45),
                    .init(color: .black.opacity(0.85), location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 14) {
                Text(show.name)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .shadow(radius: 4)

                overlayActions
            }
            .padding(16)
        }
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func backdropSection(_ url: URL) -> some View {
        Color.clear
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .overlay {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    LinearGradient(
                        colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.15)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var overlayActions: some View {
        HStack(spacing: 10) {
            overlayButton("Favorite",
                          systemImage: record?.isFavorite == true ? "heart.fill" : "heart",
                          color: .red, active: record?.isFavorite == true, action: toggleFavorite)
            overlayButton("Watched",
                          systemImage: record?.isWatched == true ? "checkmark.circle.fill" : "checkmark.circle",
                          color: .green, active: record?.isWatched == true, action: toggleWatched)
            overlayButton("Watchlist",
                          systemImage: record?.inWatchlist == true ? "bookmark.fill" : "bookmark",
                          color: .blue, active: record?.inWatchlist == true, action: toggleWatchlist)
        }
    }

    private func overlayButton(_ title: String, systemImage: String, color: Color, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemImage).font(.title3)
                Text(title).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(active ? color : .white)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var ratingRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your rating").font(.headline)
            StarRatingView(rating: record?.userRating ?? 0, onSelect: setRating)
        }
    }

    private var noteEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My note").font(.headline)
            TextField("Add a note…", text: $noteText, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onChange(of: noteText) { _, newValue in saveNote(newValue) }
        }
    }

    private var providersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Where to watch")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.providers) { provider in
                        AsyncImage(url: TMDBConfig.logoURL(provider.logoPath)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2))
                        }
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var seasonsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Seasons")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(show.displayableSeasons) { season in
                        Button {
                            selectedSeason = season
                        } label: {
                            seasonCard(season)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func seasonCard(_ season: Season) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: TMDBConfig.posterURL(season.posterPath)) { image in
                image.resizable()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    Image(systemName: "tv").foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .frame(width: 110)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(season.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            if let count = season.episodeCount {
                Text("\(count) ep\(count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 110)
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Cast").font(.headline)
                Spacer()
                if (show.credits?.cast.count ?? 0) > show.topCast.count {
                    NavigationLink("See All", value: CastListRoute(movie: show.asMovie, cast: show.credits?.cast ?? show.topCast))
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(.top, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(show.topCast) { member in
                        CastCard(member: member)
                    }
                }
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews").font(.headline)
                Spacer()
                NavigationLink("See All", value: ReviewsRoute(movie: show.asMovie, reviews: viewModel.reviews))
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.top, 4)

            ForEach(Array(viewModel.reviews.prefix(2))) { review in
                ReviewCard(review: review)
            }
        }
    }

    private var metaRow: some View {
        HStack(spacing: 14) {
            NavigationLink(value: ReviewsRoute(movie: show.asMovie, reviews: viewModel.reviews)) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text(show.ratingText)
                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)

            if !show.year.isEmpty { Text(show.year) }
            if let seasons = show.seasonsText { Text(seasons) }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(show.genres ?? []) { genre in
                    Text(genre.name)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.headline).padding(.top, 4)
    }

    @discardableResult
    private func ensureRecord() -> TrackedMovie {
        if let existing = record { return existing }
        let new = TrackedMovie(show: show)
        context.insert(new)
        return new
    }

    private func toggleWatchlist() {
        let r = ensureRecord(); r.inWatchlist.toggle(); pruneIfEmpty(r)
        AppAnalytics.trackAction("watchlist", id: show.id, mediaType: "tv")
    }

    private func toggleWatched() {
        let r = ensureRecord()
        r.isWatched.toggle()
        r.watchedDate = r.isWatched ? Date() : nil
        pruneIfEmpty(r)
        AppAnalytics.trackAction("watched", id: show.id, mediaType: "tv")
    }

    private func toggleFavorite() {
        let r = ensureRecord(); r.isFavorite.toggle(); pruneIfEmpty(r)
        AppAnalytics.trackAction("favorite", id: show.id, mediaType: "tv")
    }

    private func setRating(_ value: Int) {
        let r = ensureRecord(); r.userRating = value; pruneIfEmpty(r)
    }

    private func saveNote(_ text: String) {
        if let r = record {
            r.note = text
            pruneIfEmpty(r)
        } else if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let r = TrackedMovie(show: show)
            r.note = text
            context.insert(r)
        }
    }

    private func pruneIfEmpty(_ record: TrackedMovie) {
        if record.isEmpty { context.delete(record) }
    }
}
