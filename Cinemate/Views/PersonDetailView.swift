import SwiftUI

struct PersonDetailView: View {
    let castMember: CastMember
    @State private var viewModel: PersonDetailViewModel
    @State private var bioExpanded = false
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 14)]

    init(castMember: CastMember) {
        self.castMember = castMember
        _viewModel = State(initialValue: PersonDetailViewModel(personId: castMember.id))
    }

    private var name: String { viewModel.person?.name ?? castMember.name }
    private var profilePath: String? { viewModel.person?.profilePath ?? castMember.profilePath }

    private var filmography: [PersonCredit] {
        let credits = viewModel.person?.movieCredits?.cast ?? []
        let withPosters = credits.filter { $0.posterPath != nil && !($0.title ?? "").isEmpty }
        let sorted = withPosters.sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
        var seen = Set<Int>()
        var result: [PersonCredit] = []
        for credit in sorted where seen.insert(credit.id).inserted {
            result.append(credit)
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if let bio = viewModel.person?.biography, !bio.isEmpty {
                    biographySection(bio)
                }

                if !filmography.isEmpty {
                    filmographySection
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                }
            }
            .padding()
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: TMDBConfig.profileURL(profilePath, size: "w342")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.2))
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                Text(name).font(.title2.bold())

                if let dept = viewModel.person?.knownForDepartment, !dept.isEmpty {
                    Label(dept, systemImage: "star.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let born = viewModel.person?.bornText {
                    Label(born, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func biographySection(_ bio: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Biography").font(.headline)
            Text(bio)
                .foregroundStyle(.secondary)
                .lineLimit(bioExpanded ? nil : 6)
            Button(bioExpanded ? "Show less" : "Read more") {
                withAnimation { bioExpanded.toggle() }
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var filmographySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Known For").font(.headline)
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(filmography) { credit in
                    NavigationLink(value: credit.asMovie) {
                        filmCard(credit)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func filmCard(_ credit: PersonCredit) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: TMDBConfig.posterURL(credit.posterPath)) { image in
                image.resizable()
            } placeholder: {
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.25))
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(credit.title ?? "")
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            if let character = credit.character, !character.isEmpty {
                Text("as \(character)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else if !credit.year.isEmpty {
                Text(credit.year)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
