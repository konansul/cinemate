import Foundation
import Observation

@Observable
final class FeedGridViewModel {
    var items: [MediaItem] = []
    var isLoading = false
    var errorMessage: String?

    private var page = 0
    private var totalPages = 1
    private var feed: DiscoverFeed = .trending

    var canLoadMore: Bool { page < totalPages }

    func start(feed: DiscoverFeed) async {
        guard items.isEmpty else { return }
        self.feed = feed
        await loadMore()
    }

    func loadMore() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let next = page + 1
            let batch = try await fetch(page: next)
            page = batch.page
            totalPages = batch.totalPages
            let existing = Set(items.map(\.id))
            let fresh = batch.items.filter { !existing.contains($0.id) }
            items.append(contentsOf: fresh)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn't load more."
        }
    }

    private func fetch(page: Int) async throws -> (items: [MediaItem], page: Int, totalPages: Int) {
        switch feed {
        case .trending:
            let response = try await TMDBService.shared.trendingAllPaged(page: page)
            return (response.results.compactMap { $0.asMediaItem }, response.page ?? page, response.totalPages ?? page)
        case .popular:
            let response = try await TMDBService.shared.popularPaged(page: page)
            return (response.results.map { MediaItem(movie: $0) }, response.page, response.totalPages)
        case .topRated:
            let response = try await TMDBService.shared.topRatedPaged(page: page)
            return (response.results.map { MediaItem(movie: $0) }, response.page, response.totalPages)
        case .upcoming:
            let response = try await TMDBService.shared.upcomingPaged(page: page)
            return (response.results.map { MediaItem(movie: $0) }, response.page, response.totalPages)
        case .tvShows:
            let response = try await TMDBService.shared.trendingTVPaged(page: page)
            return (response.results.map { MediaItem(show: $0) }, response.page, response.totalPages)
        }
    }
}
