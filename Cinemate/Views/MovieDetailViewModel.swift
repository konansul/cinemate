import Foundation
import Observation

@Observable
final class MovieDetailViewModel {
    var movie: Movie
    var providers: [WatchProvider] = []
    var reviews: [Review] = []
    var isLoadingDetails = false

    init(movie: Movie) {
        self.movie = movie
    }

    func loadDetails() async {
        isLoadingDetails = true
        defer { isLoadingDetails = false }

        async let detailsTask = TMDBService.shared.details(id: movie.id)
        async let watchTask = TMDBService.shared.watchProviders(id: movie.id)
        async let reviewsTask = TMDBService.shared.reviews(id: movie.id)

        if let full = try? await detailsTask { movie = full }
        providers = (try? await watchTask) ?? []
        reviews = (try? await reviewsTask) ?? []
    }
}
