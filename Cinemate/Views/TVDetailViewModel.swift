import Foundation
import Observation

@Observable
final class TVDetailViewModel {
    var show: TVShow
    var providers: [WatchProvider] = []
    var reviews: [Review] = []
    var isLoadingDetails = false

    init(show: TVShow) {
        self.show = show
    }

    func loadDetails() async {
        isLoadingDetails = true
        defer { isLoadingDetails = false }

        async let detailsTask = TMDBService.shared.tvDetails(id: show.id)
        async let watchTask = TMDBService.shared.tvWatchProviders(id: show.id)
        async let reviewsTask = TMDBService.shared.tvReviews(id: show.id)

        if let full = try? await detailsTask { show = full }
        providers = (try? await watchTask) ?? []
        reviews = (try? await reviewsTask) ?? []
    }
}
