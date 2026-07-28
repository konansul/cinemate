import Foundation
import Observation

@Observable
final class PersonDetailViewModel {
    var person: Person?
    var isLoading = false
    var errorMessage: String?

    let personId: Int

    init(personId: Int) {
        self.personId = personId
    }

    func load() async {
        guard person == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            person = try await TMDBService.shared.person(id: personId)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn't load this person."
        }
    }
}
