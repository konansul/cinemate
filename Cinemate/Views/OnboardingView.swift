import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var page = 0
    @State private var posters: [URL] = []

    private let pages: [(title: String, subtitle: String)] = [
        ("Discover", "Trending movies and TV shows, search, cast, trailers, and where to watch — all in one place."),
        ("Track what you watch", "Build your watchlist, mark what you've seen, rate films, and jot down your own notes."),
        ("Yours, everywhere", "Your library syncs across your devices with iCloud, and reminds you when a movie is out.")
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            PosterWall(posters: posters)
                .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.35), .clear, .black.opacity(0.5), .black.opacity(0.92), .black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if page < pages.count - 1 {
                        Button("Skip") { Haptics.tap(); onFinish() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .frame(height: 30)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        textBlock(title: item.title, subtitle: item.subtitle).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 200)
                .animation(.easeInOut, value: page)
                .sensoryFeedback(.selection, trigger: page)

                dots.padding(.vertical, 18)

                Button(action: advance) {
                    Text(page == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .task { await loadPosters() }
    }

    private func textBlock(title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(index == page ? 0.95 : 0.3))
                    .frame(width: index == page ? 22 : 7, height: 7)
            }
        }
        .animation(.easeInOut, value: page)
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            Haptics.tap()
            onFinish()
        }
    }

    private func loadPosters() async {
        async let trending = TMDBService.shared.trendingAll()
        async let popular = TMDBService.shared.popular()
        let trendingItems = (try? await trending) ?? []
        let popularItems = (try? await popular) ?? []
        var urls = trendingItems.compactMap { TMDBConfig.posterURL($0.poster.posterPath) }
        urls += popularItems.compactMap { TMDBConfig.posterURL($0.posterPath) }
        posters = Array(urls.prefix(30))
    }
}

struct PosterWall: View {
    let posters: [URL]

    var body: some View {
        GeometryReader { geo in
            let overscan: CGFloat = 1.5
            let canvasW = geo.size.width * overscan
            let canvasH = geo.size.height * overscan
            let spacing: CGFloat = 10
            let targetTile: CGFloat = geo.size.width > 700 ? 180 : 120
            let cols = max(3, Int((canvasW + spacing) / (targetTile + spacing)))
            let tileWidth = (canvasW - spacing * CGFloat(cols - 1)) / CGFloat(cols)
            let columns = distribute(posters, into: cols)

            HStack(spacing: spacing) {
                ForEach(0..<cols, id: \.self) { index in
                    PosterMarqueeColumn(
                        urls: columns[index],
                        movingUp: index % 2 == 0,
                        tileWidth: tileWidth,
                        viewHeight: canvasH,
                        spacing: spacing
                    )
                }
            }
            .frame(width: canvasW, height: canvasH)
            .rotationEffect(.degrees(-16))
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .clipped()
    }

    private func distribute(_ items: [URL], into count: Int) -> [[URL]] {
        var result = Array(repeating: [URL](), count: count)
        guard !items.isEmpty else { return result }
        for (index, item) in items.enumerated() {
            result[index % count].append(item)
        }
        return result
    }
}

struct PosterMarqueeColumn: View {
    let urls: [URL]
    let movingUp: Bool
    let tileWidth: CGFloat
    let viewHeight: CGFloat
    let spacing: CGFloat

    private let speed: CGFloat = 24

    private var tileHeight: CGFloat { tileWidth * 1.5 }
    private var step: CGFloat { tileHeight + spacing }

    private var tiles: [URL] {
        guard !urls.isEmpty else { return [] }
        var result = urls
        let minHeight = viewHeight + step
        while CGFloat(result.count) * step < minHeight {
            result += urls
        }
        return result
    }

    var body: some View {
        let items = tiles
        let block = CGFloat(max(items.count, 1)) * step
        TimelineView(.animation) { timeline in
            let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
            let d = (t * speed).truncatingRemainder(dividingBy: block)

            ZStack(alignment: .top) {
                ForEach(Array(items.enumerated()), id: \.offset) { position, url in
                    let base = CGFloat(position) * step
                    let raw = movingUp ? base - d : base + d
                    tile(url).offset(y: wrap(raw, block) - tileHeight)
                }
            }
            .frame(width: tileWidth, height: viewHeight, alignment: .top)
            .clipped()
        }
        .frame(width: tileWidth, height: viewHeight)
    }

    private func wrap(_ value: CGFloat, _ block: CGFloat) -> CGFloat {
        let m = value.truncatingRemainder(dividingBy: block)
        return m < 0 ? m + block : m
    }

    private func tile(_ url: URL) -> some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(Color.white.opacity(0.06))
        }
        .frame(width: tileWidth, height: tileHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
