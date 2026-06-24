//
//  StatusSection.swift
//  spader
//

import SwiftUI

struct StatusSection: View {
    @EnvironmentObject var languageManager: LanguageManager
    let jadwalCount: Int

    var body: some View {
        let isEN = languageManager.strings.navHome == "Home"
        SectionCard {
            if jadwalCount > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isEN ? "Schedule Imported" : "Jadwal Berhasil Diimpor")
                            .font(.headline)
                        Text("\(jadwalCount) \(isEN ? "courses" : "mata kuliah")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isEN ? "No Schedule Yet" : "Belum Ada Jadwal")
                            .font(.headline)
                        Text(isEN ? "Import your schedule" : "Impor jadwal Anda")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
}
