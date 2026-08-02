import SwiftUI
import SwiftData
import FirebaseCore

@main
struct MovieApp: App {
    init() {
        FirebaseApp.configure()
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-resetOnboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: TrackedMovie.self)
    }
}
