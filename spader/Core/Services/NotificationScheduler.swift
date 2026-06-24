//
//  NotificationScheduler.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import Foundation
import UserNotifications

class NotificationScheduler {
    static let shared = NotificationScheduler()
    private init() {}
    
    private let spadaURL = "https://spada.upnyk.ac.id/login/index.php"
    
    func scheduleNotifications(
        for jadwalList: [JadwalKuliah],
        count: Int,
        gapMinutes: Int
    ) {
        for jadwal in jadwalList {
            scheduleNotification(for: jadwal, count: count, gapMinutes: gapMinutes)
        }
        print("✅ Scheduled notifications for \(jadwalList.count) jadwal")
    }
    
    private func scheduleNotification(
        for jadwal: JadwalKuliah,
        count: Int,
        gapMinutes: Int
    ) {
        guard let (day, hour, minute) = NotificationParser.extractScheduleInfo(from: jadwal.jadwal) else {
            print("⚠️ Cannot parse schedule: \(jadwal.jadwal)")
            return
        }
        
        for i in 0..<count {
            let notificationTime = calculateNotificationTime(
                hour: hour,
                minute: minute,
                reminderIndex: i,
                gapMinutes: gapMinutes
            )
            
            createNotification(
                for: jadwal,
                day: day,
                hour: notificationTime.hour,
                minute: notificationTime.minute,
                reminderIndex: i,
                gapMinutes: gapMinutes
            )
        }
    }
    
    private func calculateNotificationTime(
        hour: Int,
        minute: Int,
        reminderIndex: Int,
        gapMinutes: Int
    ) -> (hour: Int, minute: Int) {
        let classStartMinutes = hour * 60 + minute
        let minutesBefore = (reminderIndex + 1) * gapMinutes
        let notificationTotalMinutes = classStartMinutes - minutesBefore
        
        if notificationTotalMinutes < 0 {
            let adjustedMinutes = 1440 + notificationTotalMinutes
            return (adjustedMinutes / 60, adjustedMinutes % 60)
        }
        
        let notifHour = notificationTotalMinutes / 60
        let notifMinute = notificationTotalMinutes % 60
        
        return (notifHour, notifMinute)
    }
    
    private func createNotification(
        for jadwal: JadwalKuliah,
        day: Int,
        hour: Int,
        minute: Int,
        reminderIndex: Int,
        gapMinutes: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = "📚 Reminder Kuliah"
        
        // Calculate actual minutes until class starts
        let minutesUntilClass = (reminderIndex + 1) * gapMinutes
        let timeText = "\(minutesUntilClass) menit lagi"
        content.body = "\(jadwal.namaMataKuliah) dimulai \(timeText)"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("bell.aif"))
        content.badge = 1
        content.interruptionLevel = .timeSensitive
        
        content.relevanceScore = Double(minutesUntilClass) / 60.0
        
        content.userInfo = ["url": spadaURL, "jadwalId": jadwal.id.uuidString]
        content.categoryIdentifier = "JADWAL_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.weekday = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "jadwal-\(jadwal.id.uuidString)-reminder-\(reminderIndex)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled: \(jadwal.namaMataKuliah) on day \(day) at \(String(format: "%02d", hour)):\(String(format: "%02d", minute)) (\(minutesUntilClass) min before)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Gagal mengatur badge count: \(error.localizedDescription)")
            } else {
                print("🗑️ All notifications cancelled & badge reset")
            }
        }
    }
}