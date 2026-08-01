import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    var trendingMixed: [MediaItem] = []
    var popularMixed: [MediaItem] = []
    var forYou: [Movie] = []
    var topRated: [Movie] = []
    var upcoming: [Movie] = []
    var franchises: [MovieCollection] = []
    var tvShows: [TVShow] = []

    var isLoading = false
    var errorMessage: String?

    var isEmpty: Bool {
        trendingMixed.isEmpty && popularMixed.isEmpty && topRated.isEmpty && upcoming.isEmpty
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let trendingMixed = TMDBService.shared.trendingAll()
            async let popularMovies = TMDBService.shared.popular()
            async let popularShows = TMDBService.shared.popularTV()
            async let topRated = TMDBService.shared.topRated()
            async let upcoming = TMDBService.shared.upcoming()
            async let tvShows = TMDBService.shared.trendingTV()

            self.trendingMixed = try await trendingMixed
            self.popularMixed = Self.interleave(try await popularMovies, try await popularShows)
            self.topRated = try await topRated
            self.upcoming = try await upcoming
            self.tvShows = try await tvShows

            WidgetBridge.saveTrending(self.trendingMixed.map {
                WidgetFeedItem(title: $0.poster.title, posterPath: $0.poster.posterPath, backdropPath: $0.poster.backdropPath, isTV: $0.isTV)
            })
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    func loadForYou(seedId: Int) async {
        forYou = (try? await TMDBService.shared.recommendations(id: seedId)) ?? []
        WidgetBridge.saveForYou(forYou.map {
            WidgetFeedItem(title: $0.title, posterPath: $0.posterPath, backdropPath: $0.backdropPath, isTV: false)
        })
    }

    func loadFranchises() async {
        guard franchises.isEmpty else { return }
        let ids = FranchiseCatalog.ids
        var loaded: [Int: MovieCollection] = [:]
        await withTaskGroup(of: MovieCollection?.self) { group in
            for id in ids {
                group.addTask { try? await TMDBService.shared.collection(id: id) }
            }
            for await result in group {
                if let collection = result { loaded[collection.id] = collection }
            }
        }
        franchises = ids.compactMap { loaded[$0] }
    }

    static func interleave(_ movies: [Movie], _ shows: [TVShow]) -> [MediaItem] {
        let movieItems = movies.prefix(12).map { MediaItem(movie: $0) }
        let showItems = shows.prefix(12).map { MediaItem(show: $0) }
        var result: [MediaItem] = []
        let maxCount = max(movieItems.count, showItems.count)
        for index in 0..<maxCount {
            if index < movieItems.count { result.append(movieItems[index]) }
            if index < showItems.count { result.append(showItems[index]) }
        }
        return result
    }
}
