import Foundation
import Observation

@Observable
final class NewsViewModel {
    var items: [NewsItem] = []
    var isLoading = false

    func load() async {
        isLoading = true
        items = await NewsService.loadNews()
        isLoading = false
    }
}
