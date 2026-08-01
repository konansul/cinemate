import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    static let privacyPolicyURL = URL(string: "https://konansul.github.io/cinemate-legal/privacy.html")!
    static let termsOfUseURL = URL(string: "https://konansul.github.io/cinemate-legal/terms.html")!

    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    Button("Show intro again") {
                        hasCompletedOnboarding = false
                        dismiss()
                    }
                }

                Section("Data & Attribution") {
                    Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Link(destination: URL(string: "https://www.themoviedb.org")!) {
                        Label("The Movie Database (TMDB)", systemImage: "link")
                    }
                }

                Section("Legal") {
                    Link(destination: Self.privacyPolicyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: Self.termsOfUseURL) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var appVersion: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}

#Preview {
    SettingsView()
}
