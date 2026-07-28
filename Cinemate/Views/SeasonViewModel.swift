import Foundation
import Observation

@Observable
final class SeasonViewModel {
    var episodes: [Episode] = []
    var isLoading = false
    var errorMessage: String?

    let showId: Int
    let seasonNumber: Int

    init(showId: Int, seasonNumber: Int) {
        self.showId = showId
        self.seasonNumber = seasonNumber
    }

    func load() async {
        guard episodes.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let detail = try await TMDBService.shared.season(showId: showId, seasonNumber: seasonNumber)
            episodes = detail.episodes
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn't load episodes."
        }
    }
}
