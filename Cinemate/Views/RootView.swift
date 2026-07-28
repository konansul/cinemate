import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "film") }

            MyListView()
                .tabItem { Label("Library", systemImage: "rectangle.stack") }

            NewsView()
                .tabItem { Label("News", systemImage: "newspaper") }
        }
    }
}

#Preview {
    RootView()
}
