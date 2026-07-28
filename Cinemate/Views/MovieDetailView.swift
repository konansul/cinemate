import SwiftUI
import SwiftData

struct MovieDetailView: View {
    @Environment(\.modelContext) private var context
    @Query private var tracked: [TrackedMovie]
    @State private var viewModel: MovieDetailViewModel
    @State private var noteText: String = ""
    @State private var showingReviews = false
    @State private var showingCast = false
    @State private var notificationsAuthorized = false

    init(movie: Movie) {
        _viewModel = State(initialValue: MovieDetailViewModel(movie: movie))
    }

    private var movie: Movie { viewModel.movie }
    private var record: TrackedMovie? { tracked.first { $0.id == movie.id && $0.mediaType == "movie" } }
    private var shareURL: URL? { URL(string: "https://www.themoviedb.org/movie/\(movie.id)") }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                posterHeader

                metaRow

                if !(movie.genres ?? []).isEmpty { genreChips }

                if record?.inWatchlist == true, movie.isUpcoming { reminderBanner }

                ratingRow
                noteEditor

                if let trailer = movie.trailerURL {
                    Link(destination: trailer) {
                        Label("Play Trailer", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                if let backdrop = TMDBConfig.backdropURL(movie.backdropPath) {
                    backdropSection(backdrop)
                }

                if !viewModel.providers.isEmpty { providersSection }

                if let overview = movie.overview, !overview.isEmpty {
                    sectionTitle("Overview")
                    Text(overview).foregroundStyle(.secondary)
                }

                if let collection = movie.belongsToCollection {
                    collectionSection(collection)
                }

                if !movie.topCast.isEmpty { castSection }

                if !viewModel.reviews.isEmpty { reviewsSection }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingReviews) {
            ReviewsView(movie: movie, reviews: viewModel.reviews)
        }
        .navigationDestination(isPresented: $showingCast) {
            CastListView(movie: movie, cast: movie.credits?.cast ?? movie.topCast)
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
            noteText = record?.note ?? ""
            notificationsAuthorized = await NotificationManager.shared.isAuthorized()
            await viewModel.loadDetails()
        }
    }

    private var reminderBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(.blue)

            if notificationsAuthorized {
                Text("We'll remind you when it's out — \(movie.releaseDisplayText)")
                    .font(.subheadline)
                Spacer(minLength: 0)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Get a release reminder").font(.subheadline.weight(.semibold))
                    Text("Out \(movie.releaseDisplayText)").font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Button("Enable") { Task { await enableReminder() } }
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func enableReminder() async {
        await NotificationManager.shared.scheduleReleaseReminder(
            movieId: movie.id, title: movie.title, releaseDate: movie.releaseDate
        )
        notificationsAuthorized = await NotificationManager.shared.isAuthorized()
    }

    private var posterHeader: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: TMDBConfig.posterURL(movie.posterPath)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    Image(systemName: "film").font(.largeTitle).foregroundStyle(.secondary)
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
                Text(movie.title)
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
        AsyncImage(url: url) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            LinearGradient(
                colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.15)],
                startPoint: .top, endPoint: .bottom
            )
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var overlayActions: some View {
        HStack(spacing: 10) {
            overlayButton("Watchlist",
                          systemImage: record?.inWatchlist == true ? "bookmark.fill" : "bookmark",
                          color: .blue, active: record?.inWatchlist == true, action: toggleWatchlist)
            overlayButton("Watched",
                          systemImage: record?.isWatched == true ? "checkmark.circle.fill" : "checkmark.circle",
                          color: .green, active: record?.isWatched == true, action: toggleWatched)
            overlayButton("Favorite",
                          systemImage: record?.isFavorite == true ? "heart.fill" : "heart",
                          color: .red, active: record?.isFavorite == true, action: toggleFavorite)
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

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Cast").font(.headline)
                Spacer()
                if (movie.credits?.cast.count ?? 0) > movie.topCast.count {
                    Button("See All") { showingCast = true }
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(.top, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(movie.topCast) { member in
                        CastCard(member: member)
                    }
                }
            }
        }
    }

    private func collectionSection(_ collection: BelongsToCollection) -> some View {
        NavigationLink(value: collection) {
            HStack(spacing: 12) {
                AsyncImage(url: TMDBConfig.posterURL(collection.posterPath, size: "w185")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.25))
                        Image(systemName: "square.stack").foregroundStyle(.secondary)
                    }
                }
                .frame(width: 50, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Part of").font(.caption).foregroundStyle(.secondary)
                    Text(collection.name).font(.headline).lineLimit(2)
                    Text("See all movies").font(.caption).foregroundStyle(.blue)
                }

                Spacer()
                Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews").font(.headline)
                Spacer()
                Button("See All") { showingReviews = true }
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
            Button {
                showingReviews = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text(movie.ratingText)
                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)

            if !movie.year.isEmpty { Text(movie.year) }
            if let runtime = movie.runtimeText { Text(runtime) }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(movie.genres ?? []) { genre in
                    NavigationLink(value: genre) {
                        Text(genre.name)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
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
        let new = TrackedMovie(movie: movie)
        context.insert(new)
        return new
    }

    private func toggleWatchlist() {
        let r = ensureRecord()
        r.inWatchlist.toggle()
        let isOn = r.inWatchlist
        pruneIfEmpty(r)
        Task {
            if isOn {
                await NotificationManager.shared.scheduleReleaseReminder(
                    movieId: movie.id, title: movie.title, releaseDate: movie.releaseDate
                )
                notificationsAuthorized = await NotificationManager.shared.isAuthorized()
            } else {
                NotificationManager.shared.cancelReleaseReminder(movieId: movie.id)
            }
        }
    }

    private func toggleWatched() {
        let r = ensureRecord()
        r.isWatched.toggle()
        r.watchedDate = r.isWatched ? Date() : nil
        pruneIfEmpty(r)
    }

    private func toggleFavorite() {
        let r = ensureRecord(); r.isFavorite.toggle(); pruneIfEmpty(r)
    }

    private func setRating(_ value: Int) {
        let r = ensureRecord(); r.userRating = value; pruneIfEmpty(r)
    }

    private func saveNote(_ text: String) {
        if let r = record {
            r.note = text
            pruneIfEmpty(r)
        } else if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let r = TrackedMovie(movie: movie)
            r.note = text
            context.insert(r)
        }
    }

    private func pruneIfEmpty(_ record: TrackedMovie) {
        if record.isEmpty { context.delete(record) }
    }
}
