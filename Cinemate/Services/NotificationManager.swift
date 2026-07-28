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
