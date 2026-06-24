//
//  SettingsButtons.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct SettingsButtons: View {
    let hasJadwal: Bool
    @Binding var showAppearanceSettings: Bool
    @Binding var showNotificationSettings: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Appearance Settings
            Button {
                showAppearanceSettings = true
            } label: {
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                        .frame(width: 30)
                    Text(languageManager.strings.settingsAppearance)
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.primary)
                .padding()
                .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                .cornerRadius(12)
            }
            
            // Notification Settings
            if hasJadwal {
                Button {
                    showNotificationSettings = true
                } label: {
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(languageManager.strings.settingsNotification)
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}