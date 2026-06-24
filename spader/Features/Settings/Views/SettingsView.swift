// Features/Settings/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("name") private var userName = ""
    @Environment(\.colorScheme) var colorScheme

    @State private var showManageSchedule = false
    @State private var showProfileView = false
    @State private var showResetAlert = false
    @State private var showAbout = false
    @State private var showNotificationSettings = false
    @State private var showAppearanceSettings = false
    @State private var showLanguagePicker = false

    var body: some View {
        let s = languageManager.strings
        ZStack {
            GradientBackground()

            ScrollView {
                VStack(spacing: 20) {
                    ProfileSection(userName: userName) {
                        showProfileView = true
                    }
                    .padding(.horizontal, 20)

                    Button(action: { showManageSchedule = true }) {
                        HStack {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.settingsManageSchedule)
                                    .font(.headline)
                                Text("\(scheduleManager.jadwalList.count) \(s.navTugas == "Tasks" ? "courses" : "mata kuliah")")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 3)
                    }
                    .padding(.horizontal, 20)

                    SettingsButtons(
                        hasJadwal: !scheduleManager.jadwalList.isEmpty,
                        showAppearanceSettings: $showAppearanceSettings,
                        showNotificationSettings: $showNotificationSettings
                    )
                    .padding(.horizontal, 20)

                    // Language card
                    Button(action: { showLanguagePicker = true }) {
                        HStack {
                            Image(systemName: "globe")
                                .font(.title3)
                                .foregroundColor(.green)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.settingsLanguage)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(languageManager.currentLanguage == "EN" ? s.langEnglish : s.langIndonesia)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    BottomButtons(showResetAlert: $showResetAlert, showAbout: $showAbout)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showManageSchedule) {
            ManageScheduleView()
                .environmentObject(scheduleManager)
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showProfileView) {
            ProfileView()
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
                .environmentObject(scheduleManager)
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showAppearanceSettings) {
            AppearanceSettingsView()
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView()
                .environmentObject(languageManager)
        }
        .alert(s.settingsResetTitle, isPresented: $showResetAlert) {
            Button(s.actionCancel, role: .cancel) {}
            Button(s.actionReset, role: .destructive) { resetApp() }
        } message: {
            Text(s.settingsResetBody)
        }
        .alert(s.settingsAbout, isPresented: $showAbout) {
            Button(s.actionOK, role: .cancel) {}
        } message: {
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            Text("\(s.aboutDeveloper): Wildan Rifqi\n\(s.aboutEmail): wildanrfqi@gmail.com\n\(s.aboutVersion): \(version)")
        }
    }

    func resetApp() {
        scheduleManager.clearAll()
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "savedJadwalList")
        UserDefaults.standard.removeObject(forKey: "appearance")
        exit(0)
    }
}

struct LanguagePickerView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let s = languageManager.strings
        NavigationView {
            List {
                ForEach([("ID", "🇮🇩", s.langIndonesia), ("EN", "🇬🇧", s.langEnglish)], id: \.0) { code, flag, label in
                    Button(action: {
                        languageManager.setLanguage(code)
                        dismiss()
                    }) {
                        HStack {
                            Text(flag).font(.title2)
                            Text(label)
                                .foregroundColor(.primary)
                                .fontWeight(languageManager.currentLanguage == code ? .semibold : .regular)
                            Spacer()
                            if languageManager.currentLanguage == code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(s.settingsLanguage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.actionCancel) { dismiss() }
                }
            }
        }
    }
}
