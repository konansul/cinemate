import Foundation
import Observation

@Observable
final class SearchViewModel {
    var query = ""
    var results: [MediaItem] = []
    var isSearching = false
    var hasSearched = false

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            hasSearched = false
            return
        }
        isSearching = true
        hasSearched = true
        results = (try? await TMDBService.shared.searchMulti(trimmed)) ?? []
        isSearching = false
        AppAnalytics.search(trimmed)
    }
}
