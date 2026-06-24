//
//  NotificationSettingsView.swift
//  spader
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject var scheduleManager: ScheduleManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var pendingNotificationsCount = 0
    @State private var showPermissionAlert = false
    @State private var isTesting = false
    @State private var showSuccess = false

    var body: some View {
        let s = languageManager.strings
        let isEN = s.navHome == "Home"

        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ? [
                        Color(white: 0.1), Color(white: 0.15)
                    ] : [
                        Color(white: 0.98), Color(white: 0.92)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: Status Section
                        SectionHeader(isEN ? "Notification Permission" : "Izin Notifikasi")
                        SectionCard {
                            HStack {
                                Image(systemName: notificationManager.isAuthorized ? "bell.fill" : "bell.slash.fill")
                                    .foregroundColor(notificationManager.isAuthorized ? .green : .red)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isEN ? "Notification Status" : "Status Notifikasi")
                                        .font(.headline)
                                    Text(notificationManager.isAuthorized ? (isEN ? "Active" : "Aktif") : (isEN ? "Inactive" : "Nonaktif"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if !notificationManager.isAuthorized {
                                    Button(isEN ? "Enable" : "Aktifkan") {
                                        openAppSettings()
                                    }
                                    .font(.subheadline)
                                }
                            }
                        }

                        // MARK: Reminder Toggle
                        SectionHeader(isEN ? "Reminder Settings" : "Pengaturan Reminder")
                        SectionCard {
                            Toggle(isEN ? "Enable Reminder" : "Aktifkan Reminder",
                                   isOn: $notificationManager.notificationEnabled)
                                .onChange(of: notificationManager.notificationEnabled) { _, newValue in
                                    if newValue { applyNotificationSettings() }
                                    else { notificationManager.cancelAllNotifications() }
                                }
                        }
                        SectionFooter(isEN
                            ? "Enable to receive reminders before class starts"
                            : "Aktifkan untuk mendapatkan reminder sebelum jadwal kuliah dimulai")

                        if notificationManager.notificationEnabled {

                            // MARK: Reminder Count
                            SectionHeader(isEN ? "Reminder Frequency" : "Frekuensi Reminder")
                            SectionCard {
                                Stepper(value: $notificationManager.notificationCount, in: 1...5) {
                                    HStack {
                                        Text(isEN ? "Reminder Count" : "Jumlah Reminder")
                                        Spacer()
                                        Text("\(notificationManager.notificationCount)x")
                                            .foregroundColor(.blue)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .onChange(of: notificationManager.notificationCount) { _, _ in
                                    applyNotificationSettings()
                                }

                                Divider().padding(.vertical, 8)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(isEN ? "Send times:" : "Waktu Pengiriman:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    ForEach(0..<notificationManager.notificationCount, id: \.self) { index in
                                        let minutes = (index + 1) * notificationManager.notificationGapMinutes
                                        HStack {
                                            Circle().fill(Color.blue).frame(width: 6, height: 6)
                                            Text(isEN
                                                ? "\(minutes) min before class"
                                                : "\(minutes) menit sebelum kuliah")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            SectionFooter(isEN
                                ? "How many reminders will be sent before class starts"
                                : "Berapa kali reminder akan dikirim sebelum kuliah dimulai")

                            // MARK: Gap Minutes
                            SectionHeader(isEN ? "Reminder Interval" : "Interval Antar Reminder")
                            SectionCard(alignment: .leading) {
                                HStack {
                                    Text(isEN ? "Time Interval" : "Interval Waktu")
                                    Spacer()
                                    Menu {
                                        Button(isEN ? "5 minutes" : "5 menit")  { notificationManager.notificationGapMinutes = 5 }
                                        Button(isEN ? "10 minutes" : "10 menit") { notificationManager.notificationGapMinutes = 10 }
                                        Button(isEN ? "15 minutes" : "15 menit") { notificationManager.notificationGapMinutes = 15 }
                                        Button(isEN ? "30 minutes" : "30 menit") { notificationManager.notificationGapMinutes = 30 }
                                        Button(isEN ? "60 minutes" : "60 menit") { notificationManager.notificationGapMinutes = 60 }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(isEN
                                                ? "\(notificationManager.notificationGapMinutes) min"
                                                : "\(notificationManager.notificationGapMinutes) menit")
                                                .foregroundColor(.blue)
                                                .fontWeight(.semibold)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }

                                Divider()

                                Text(isEN
                                    ? "Time gap between each reminder"
                                    : "Jarak waktu antara setiap reminder")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .onChange(of: notificationManager.notificationGapMinutes) { _, _ in
                                applyNotificationSettings()
                            }

                            // MARK: Info
                            SectionHeader(isEN ? "Information" : "Informasi")
                            SectionCard {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    Text(isEN ? "Scheduled Notifications" : "Notifikasi Terjadwal")
                                    Spacer()
                                    Text("\(pendingNotificationsCount)")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }

                            // MARK: Test Button
                            SectionCard {
                                Button(action: { testNotification(isEN: isEN) }) {
                                    HStack {
                                        Spacer()
                                        if isTesting {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text(isEN ? "Sending..." : "Mengirim...")
                                                .foregroundColor(.white).fontWeight(.semibold)
                                                .transition(.opacity)
                                        } else if showSuccess {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white).imageScale(.large)
                                                .transition(.scale)
                                            Text(isEN ? "Sent!" : "Berhasil!")
                                                .foregroundColor(.white).fontWeight(.semibold)
                                                .transition(.opacity)
                                        } else {
                                            Image(systemName: "bell.badge.fill").foregroundColor(.white)
                                            Text(isEN ? "Test Notification" : "Test Notifikasi")
                                                .foregroundColor(.white).fontWeight(.semibold)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(isTesting ? Color.gray : (showSuccess ? Color.green : Color.orange))
                                    .cornerRadius(12)
                                }
                                .disabled(isTesting || showSuccess)
                                .animation(.easeInOut(duration: 0.25), value: isTesting)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSuccess)
                            }
                        }

                        // MARK: How It Works
                        SectionHeader(isEN ? "How It Works" : "Cara Kerja")
                        SectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(isEN ? "Class at 10:00" : "Kuliah jam 10:00")
                                    .font(.body).fontWeight(.medium)

                                Text(isEN ? "Reminders sent at:" : "Reminder dikirim:")
                                    .font(.caption).foregroundColor(.secondary)
                                    .padding(.vertical, 4)

                                ForEach(getExampleTimes(isEN: isEN), id: \.self) { time in
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.fill")
                                            .font(.caption).foregroundColor(.blue).frame(width: 16)
                                        Text(time)
                                            .font(.caption).foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle(s.notifTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEN ? "Done" : "Selesai") { dismiss() }
                }
            }
            .onAppear {
                notificationManager.checkAuthorizationStatus()
                updatePendingCount()
            }
        }
    }

    private func applyNotificationSettings() {
        guard notificationManager.isAuthorized else { showPermissionAlert = true; return }
        notificationManager.scheduleNotifications(for: scheduleManager.jadwalList)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { updatePendingCount() }
    }

    private func updatePendingCount() {
        notificationManager.getPendingNotificationsCount { count in
            pendingNotificationsCount = count
        }
    }

    private func testNotification(isEN: Bool) {
        isTesting = true
        showSuccess = false

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "📚 Test Reminder"
            content.body = isEN ? "This is a test notification." : "Notifikasi ini adalah sebuah testing."
            content.sound = UNNotificationSound(named: UNNotificationSoundName("bell.aif"))
            content.interruptionLevel = .timeSensitive

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { isTesting = false; showSuccess = true }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { showSuccess = false }
                }
            }
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func getExampleTimes(isEN: Bool) -> [String] {
        var times: [String] = []
        for i in 0..<notificationManager.notificationCount {
            let minutes = (i + 1) * notificationManager.notificationGapMinutes
            let notifMin = 10 * 60 - minutes
            let h = notifMin / 60
            let m = notifMin % 60
            times.append("\(h):\(String(format: "%02d", m)) (\(minutes) \(isEN ? "min before" : "menit sebelumnya"))")
        }
        return times.reversed()
    }
}
