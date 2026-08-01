import SwiftUI
import SwiftData

@main
struct MovieApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: TrackedMovie.self)
    }
}
