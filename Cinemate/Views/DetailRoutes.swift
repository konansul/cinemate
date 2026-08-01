import Foundation

struct CastListRoute: Hashable {
    let movie: Movie
    let cast: [CastMember]
}

struct ReviewsRoute: Hashable {
    let movie: Movie
    let reviews: [Review]
}
