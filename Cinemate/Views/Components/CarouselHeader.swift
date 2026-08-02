import SwiftUI

struct CarouselHeader: View {
    let title: String
    var feed: DiscoverFeed? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title2.bold())
            Spacer()
            if let feed {
                NavigationLink(value: feed) {
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}
