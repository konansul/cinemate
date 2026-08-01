import SwiftUI
import SwiftData
import FirebaseCore

@main
struct MovieApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: TrackedMovie.self)
    }
}
