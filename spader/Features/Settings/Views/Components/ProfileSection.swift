//
//  ProfileSection.swift
//  spader
//

import SwiftUI

struct ProfileSection: View {
    @EnvironmentObject var languageManager: LanguageManager
    let userName: String
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let s = languageManager.strings
        Button(action: onTap) {
            SectionCard {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Text(getInitials(from: userName))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName.isEmpty ? (s.navHome == "Home" ? "No name yet" : "Belum ada nama") : userName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(s.navHome == "Home" ? "View profile & GPA" : "Lihat profil & IPK")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func getInitials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.isEmpty { return "?" }
        else if words.count == 1 { return String(words[0].prefix(1)).uppercased() }
        else { return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased() }
    }
}
