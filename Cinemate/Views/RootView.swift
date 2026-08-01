import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { newValue in if !newValue { hasCompletedOnboarding = true } }
        )
    }

    var body: some View {
        tabs
        .task {
            if hasCompletedOnboarding {
                await enableDailyNudges()
            }
        }
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingView {
                hasCompletedOnboarding = true
                Task { await enableDailyNudges() }
            }
        }
    }

    private var tabs: some View {
        TabView {
            Tab("Discover", systemImage: "film") {
                DiscoverView()
            }
            Tab("Library", systemImage: "rectangle.stack") {
                MyListView()
            }
            Tab("News", systemImage: "newspaper") {
                NewsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    private func enableDailyNudges() async {
        _ = await NotificationManager.shared.requestAuthorization()
        await NotificationManager.shared.refreshDailyNudges()
    }
}
