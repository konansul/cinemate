import Foundation
import Observation

@Observable
final class GenreMoviesViewModel {
    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?

    private var page = 0
    private var totalPages = 1
    private var genreId = 0

    var canLoadMore: Bool { page < totalPages }

    func start(genreId: Int) async {
        guard movies.isEmpty else { return }
        self.genreId = genreId
        await loadMore()
    }

    func loadMore() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await TMDBService.shared.discover(genreId: genreId, page: page + 1)
            page = response.page
            totalPages = response.totalPages
            let existing = Set(movies.map(\.id))
            let fresh = response.results.filter { !existing.contains($0.id) }
            movies.append(contentsOf: fresh)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn't load movies."
        }
    }
}
