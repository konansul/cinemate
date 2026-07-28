import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var remindersEnabled = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Release reminders", systemImage: "bell.badge")
                        Spacer()
                        Text(remindersEnabled ? "On" : "Off")
                            .foregroundStyle(remindersEnabled ? .green : .secondary)
                    }
                    if !remindersEnabled {
                        Button("Turn on in Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get notified on release day for upcoming movies you add to your Watchlist.")
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                }

                Section("Data & Attribution") {
                    Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Link(destination: URL(string: "https://www.themoviedb.org")!) {
                        Label("The Movie Database (TMDB)", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                remindersEnabled = await NotificationManager.shared.isAuthorized()
            }
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
