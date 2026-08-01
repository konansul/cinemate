import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    func requestAuthorization() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    func scheduleReleaseReminder(movieId: Int, title: String, releaseDate: String?) async {
        guard let fireDate = Self.reminderDate(from: releaseDate) else { return }
        guard await requestAuthorization() else { return }
        await add(movieId: movieId, title: title, fireDate: fireDate)
    }

    func syncReleaseReminders(for movies: [(id: Int, title: String, releaseDate: String?)]) async {
        guard await isAuthorized() else { return }
        for movie in movies {
            guard let fireDate = Self.reminderDate(from: movie.releaseDate) else { continue }
            await add(movieId: movie.id, title: movie.title, fireDate: fireDate)
        }
    }

    func cancelReleaseReminder(movieId: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(movieId)])
    }

    private static let nudgePrefix = "daily-nudge-"
    private static let nudgeHorizon = 14

    private static let nudges: [(title: String, body: String)] = [
        ("Movie time? 🍿", "See what's trending and line up your next watch."),
        ("Your watchlist misses you", "There's something in there you meant to get to."),
        ("Two hours to spare?", "Pick something from your list and press play."),
        ("New picks are in 🎬", "Trending titles just refreshed on Cinemate."),
        ("Still thinking about it?", "That title you saved isn't going to watch itself."),
        ("Tonight's the night 🌙", "Open Cinemate and settle on something good."),
        ("Seen anything lately?", "Mark it watched and give it a rating."),
        ("Quiet evening ahead?", "Your watchlist has a few ideas."),
        ("Trending now 🔥", "See what everyone is watching this week."),
        ("Rate what you've seen ⭐️", "A quick rating keeps your library sharp."),
        ("Something new to add?", "Browse by genre and find your next favorite."),
        ("Coffee and a trailer? ☕️", "Five minutes is enough to find something."),
        ("Your library is waiting", "Favorites, watched and watchlist, all in one place."),
        ("Weekend plans sorted 🎥", "Line up a couple of films from your watchlist."),
        ("Missed anything? 📺", "New shows are trending on Cinemate."),
        ("One more for the list", "Search that title you've been meaning to see.")
    ]

    private static let nudgeHours = [9, 12, 15, 18, 20, 11, 21]

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    func refreshDailyNudges() async {
        guard await isAuthorized() else { return }

        let stale = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(Self.nudgePrefix) }
        center.removePendingNotificationRequests(withIdentifiers: stale)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for offset in 0..<Self.nudgeHorizon {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let index = Self.dayIndex(for: day)
            let hour = Self.nudgeHours[index % Self.nudgeHours.count]
            let minute = (index * 17) % 60
            guard let fire = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day),
                  fire > Date() else { continue }

            let nudge = Self.nudges[index % Self.nudges.count]
            let content = UNMutableNotificationContent()
            content.title = nudge.title
            content.body = nudge.body
            content.sound = .default

            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: Self.nudgePrefix + Self.dayFormatter.string(from: day),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    private static func dayIndex(for day: Date) -> Int {
        let reference = Date(timeIntervalSince1970: 0)
        let days = Calendar.current.dateComponents([.day], from: reference, to: day).day ?? 0
        return abs(days)
    }

    private func add(movieId: Int, title: String, fireDate: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Out today 🍿"
        content.body = "\(title) is out now. Time to watch."
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier(movieId), content: content, trigger: trigger)
        try? await center.add(request)
    }

    static func identifier(_ movieId: Int) -> String { "release-\(movieId)" }

    static func reminderDate(from releaseDate: String?) -> Date? {
        guard let releaseDate, !releaseDate.isEmpty else { return nil }
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")
        guard let day = parser.date(from: releaseDate) else { return nil }
        guard let fire = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: day) else { return nil }
        return fire > Date() ? fire : nil
    }
}
