import Foundation
import Observation

@Observable
final class CollectionViewModel {
    var collection: MovieCollection?
    var isLoading = false
    var errorMessage: String?

    let collectionId: Int

    init(collectionId: Int) {
        self.collectionId = collectionId
    }

    var sortedParts: [Movie] {
        let parts = collection?.parts ?? []
        return parts.sorted { a, b in
            let da = a.releaseDate ?? ""
            let db = b.releaseDate ?? ""
            if da.isEmpty != db.isEmpty { return !da.isEmpty }
            return da < db
        }
    }

    func load() async {
        guard collection == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            collection = try await TMDBService.shared.collection(id: collectionId)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn't load this collection."
        }
    }
}
