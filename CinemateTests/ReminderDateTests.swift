import Foundation
import Testing
@testable import Cinemate

@Suite("Release reminder dates")
@MainActor
struct ReminderDateTests {
    @Test func returnsNilWhenDateIsMissing() {
        #expect(NotificationManager.reminderDate(from: nil) == nil)
        #expect(NotificationManager.reminderDate(from: "") == nil)
    }

    @Test func returnsNilForUnparsableDate() {
        #expect(NotificationManager.reminderDate(from: "not a date") == nil)
        #expect(NotificationManager.reminderDate(from: "2026") == nil)
        #expect(NotificationManager.reminderDate(from: "01-05-2030") == nil)
    }

    @Test func returnsNilForReleasesInThePast() {
        #expect(NotificationManager.reminderDate(from: "2000-01-01") == nil)
    }

    @Test func schedulesFutureReleaseAtTenInTheMorning() throws {
        let date = try #require(NotificationManager.reminderDate(from: "2099-06-15"))

        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        #expect(parts.year == 2099)
        #expect(parts.month == 6)
        #expect(parts.day == 15)
        #expect(parts.hour == 10)
        #expect(parts.minute == 0)
    }
}
