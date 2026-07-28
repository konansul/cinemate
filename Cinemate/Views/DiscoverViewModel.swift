import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    var trending: [Movie] = []
    var popular: [Movie] = []
    var topRated: [Movie] = []
    var upcoming: [Movie] = []
    var forYou: [Movie] = []
    var franchises: [MovieCollection] = []

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
}
