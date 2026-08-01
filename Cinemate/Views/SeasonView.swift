import SwiftUI

struct SeasonView: View {
    let showId: Int
    let showName: String
    let season: Season
    @State private var viewModel: SeasonViewModel

    init(showId: Int, showName: String, season: Season) {
        self.showId = showId
        self.showName = showName
        self.season = season
        _viewModel = State(initialValue: SeasonViewModel(showId: showId, seasonNumber: season.seasonNumber))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if let overview = season.overview, !overview.isEmpty {
                    Text(overview).foregroundStyle(.secondary)
                }

                if viewModel.episodes.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                } else {
                    ForEach(viewModel.episodes) { episode in
                        episodeRow(episode)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(season.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(showName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(season.name)
                .font(.title2.bold())
            if let count = season.episodeCount {
                Text("\(count) episode\(count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func episodeRow(_ episode: Episode) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: TMDBConfig.backdropURL(episode.stillPath, size: "w300")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.2))
                    Image(systemName: "tv").foregroundStyle(.secondary)
                }
            }
            .frame(width: 128, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(episode.episodeNumber). \(episode.name ?? "Episode \(episode.episodeNumber)")")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if !episode.airYearText.isEmpty { Text(episode.airYearText) }
                    if let runtime = episode.runtimeText { Text(runtime) }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                if let overview = episode.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
