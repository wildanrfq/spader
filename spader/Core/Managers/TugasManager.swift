//
//  TugasManager.swift
//  spader
//
//  Core/Managers/TugasManager.swift
//

import Foundation
import SwiftUI
import UserNotifications
internal import Combine

class TugasManager: ObservableObject {
    static let shared = TugasManager()

    @Published var tugasList: [Tugas] = [] {
        didSet { save() }
    }

    private let key = "savedTugasList"

    init() { load() }

    // MARK: - CRUD

    func tambah(_ tugas: Tugas) {
        tugasList.append(tugas)
        sort()
        scheduleNotification(for: tugas)
    }

    func update(_ tugas: Tugas) {
        guard let i = tugasList.firstIndex(where: { $0.id == tugas.id }) else { return }
        cancelNotification(for: tugasList[i])
        tugasList[i] = tugas
        sort()
        if !tugas.isSelesai {
            scheduleNotification(for: tugas)
        }
    }

    func hapus(_ tugas: Tugas) {
        cancelNotification(for: tugas)
        tugasList.removeAll { $0.id == tugas.id }
    }

    func toggleSelesai(_ tugas: Tugas) {
        guard let i = tugasList.firstIndex(where: { $0.id == tugas.id }) else { return }
        tugasList[i].isSelesai.toggle()
        if tugasList[i].isSelesai {
            cancelNotification(for: tugasList[i])
        } else {
            scheduleNotification(for: tugasList[i])
        }
        sort()
    }

    // MARK: - Filters

    var aktif: [Tugas] {
        tugasList.filter { !$0.isSelesai }.sorted { a, b in
            if a.isOverdue != b.isOverdue { return a.isOverdue }
            if a.prioritas != b.prioritas {
                let order: [TugasPrioritas] = [.tinggi, .sedang, .rendah]
                return (order.firstIndex(of: a.prioritas) ?? 0) < (order.firstIndex(of: b.prioritas) ?? 0)
            }
            return a.deadline < b.deadline
        }
    }

    var selesai: [Tugas] {
        tugasList.filter { $0.isSelesai }.sorted { $0.deadline > $1.deadline }
    }

    var deadlineSoon: [Tugas] {
        tugasList.filter { $0.isDeadlineSoon }
    }

    var overdueCount: Int {
        tugasList.filter { $0.isOverdue }.count
    }

    var aktifCount: Int {
        tugasList.filter { !$0.isSelesai }.count
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(tugasList) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([Tugas].self, from: data) else { return }
        tugasList = list
    }

    private func sort() {
        tugasList = tugasList.sorted { a, b in
            if a.isSelesai != b.isSelesai { return !a.isSelesai }
            return a.deadline < b.deadline
        }
    }

    // MARK: - Notifications

    func scheduleNotification(for tugas: Tugas) {
        guard tugas.deadline > Date() else { return }

        let reminders: [(label: String, offset: TimeInterval)] = [
            ("H-3", -3 * 24 * 3600),
            ("H-1", -1 * 24 * 3600),
            ("3 jam", -3 * 3600),
            ("1 jam", -1 * 3600)
        ]

        for reminder in reminders {
            let fireDate = tugas.deadline.addingTimeInterval(reminder.offset)
            guard fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "📝 Deadline Tugas"
            content.body = "\(tugas.judul) — \(tugas.mataKuliah) • \(reminder.label) lagi"
            content.sound = .default
            content.badge = 1
            content.interruptionLevel = .timeSensitive
            content.userInfo = ["tugasId": tugas.id.uuidString]
            content.categoryIdentifier = "TUGAS_DEADLINE"

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let id = "tugas-\(tugas.id.uuidString)-\(reminder.label)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Tugas notif error: \(error)")
                } else {
                    print("✅ Tugas reminder scheduled: \(tugas.judul) @ \(fireDate)")
                }
            }
        }
    }

    func cancelNotification(for tugas: Tugas) {
        let labels = ["H-3", "H-1", "3 jam", "1 jam"]
        let ids = labels.map { "tugas-\(tugas.id.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
