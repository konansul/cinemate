import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    var trending: [Movie] = []
    var popular: [Movie] = []
    var topRated: [Movie] = []
    var upcoming: [Movie] = []
    var forYou: [Movie] = []

    var isLoading = false
    var errorMessage: String?

    var isEmpty: Bool {
        trending.isEmpty && popular.isEmpty && topRated.isEmpty && upcoming.isEmpty
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let trending = TMDBService.shared.trending()
            async let popular = TMDBService.shared.popular()
            async let topRated = TMDBService.shared.topRated()
            async let upcoming = TMDBService.shared.upcoming()

            self.trending = try await trending
            self.popular = try await popular
            self.topRated = try await topRated
            self.upcoming = try await upcoming
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    func loadForYou(seedId: Int) async {
        forYou = (try? await TMDBService.shared.recommendations(id: seedId)) ?? []
    }
}
