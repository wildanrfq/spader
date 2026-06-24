//
//  NotificationManager.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


// Core/Managers/NotificationManager.swift
import Foundation
import UserNotifications
import UIKit
internal import Combine
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    @AppStorage("notificationEnabled") var notificationEnabled = true
    @AppStorage("notificationCount") var notificationCount = 3
    @AppStorage("notificationGapMinutes") var notificationGapMinutes = 15
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Request Permission
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                } else {
                    print(granted ? "✅ Notification permission granted" : "⚠️ Notification permission denied")
                }
            }
        }
    }
    
    // MARK: - Check Permission Status
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Notifications
    func scheduleNotifications(for jadwalList: [JadwalKuliah]) {
        guard notificationEnabled else {
            print("ℹ️ Notifikasi dinonaktifkan")
            return
        }
        
        NotificationScheduler.shared.cancelAllNotifications()
        NotificationScheduler.shared.scheduleNotifications(
            for: jadwalList,
            count: notificationCount,
            gapMinutes: notificationGapMinutes
        )
    }
    
    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        NotificationScheduler.shared.cancelAllNotifications()
    }
    
    // MARK: - Get Pending Notifications Count
    func getPendingNotificationsCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
    
    // MARK: - Setup Notification Categories
    func setupNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_SPADA",
            title: "Buka Spada",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "JADWAL_REMINDER",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let urlString = userInfo["url"] as? String,
           let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
        
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Gagal reset badge count: \(error.localizedDescription)")
            }
        }
        
        completionHandler()
    }
}