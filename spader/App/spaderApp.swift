import SwiftUI
import UserNotifications
@_exported import HotSwiftUI
internal import Combine

@main
struct spaderApp: App {
    @ObserveInjection var inject
    @StateObject private var scheduleManager = ScheduleManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @AppStorage("appearance") private var appearance: AppearanceMode = .system

    init() {
        NotificationManager.shared.setupNotificationCategories()
        setupTugasNotificationCategory()
    }

    private func setupTugasNotificationCategory() {
        let doneAction = UNNotificationAction(
            identifier: "MARK_DONE",
            title: "Tandai Selesai",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "TUGAS_DEADLINE",
            actions: [doneAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(scheduleManager)
                .environmentObject(notificationManager)
                .environmentObject(languageManager)
                .preferredColorScheme(appearance.colorScheme)
                .enableInjection()
                .onAppear {
                    notificationManager.requestAuthorization()
                    if !scheduleManager.jadwalList.isEmpty {
                        notificationManager.scheduleNotifications(for: scheduleManager.jadwalList)
                    }
                }
        }
    }
}
