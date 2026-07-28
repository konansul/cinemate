import SwiftUI

struct NewsView: View {
    @State private var viewModel = NewsViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            content
                .toolbar(.hidden, for: .navigationBar)
                .task {
                    if viewModel.items.isEmpty { await viewModel.load() }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.items.isEmpty && viewModel.isLoading {
            ProgressView("Loading news…")
        } else if viewModel.items.isEmpty {
            ContentUnavailableView(
                "No news",
                systemImage: "newspaper",
                description: Text("Couldn't load news right now. Pull to refresh.")
            )
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("News")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                    ForEach(viewModel.items) { item in
                        Button {
                            openURL(item.link)
                        } label: {
                            NewsRow(item: item)
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading)
                    }
                }
            }
            .refreshable { await viewModel.load() }
        }
    }
}

struct NewsRow: View {
    let item: NewsItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                HStack(spacing: 6) {
                    Text(item.source)
                        .foregroundStyle(.blue)
                    if let date = item.date {
                        Text("· \(date.formatted(.relative(presentation: .named)))")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var thumbnail: some View {
        AsyncImage(url: item.imageURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ZStack {
                Rectangle().fill(Color.gray.opacity(0.15))
                Image(systemName: "newspaper")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 108, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
