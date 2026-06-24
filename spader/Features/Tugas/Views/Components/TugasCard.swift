//
//  TugasCard.swift
//  spader
//

import SwiftUI

struct TugasCard: View {
    let tugas: Tugas
    let onToggle: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme

    private var isEN: Bool { languageManager.strings.navHome == "Home" }
    private var s: AppStrings { languageManager.strings }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(tugas.isSelesai ? Color.green : borderColor, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if tugas.isSelesai {
                        Circle().fill(Color.green).frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onTap) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(tugas.mataKuliahColor)
                        .frame(width: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tugas.judul)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(tugas.isSelesai ? .secondary : .primary)
                            .strikethrough(tugas.isSelesai)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(tugas.mataKuliahColor)
                                .frame(width: 6, height: 6)
                            Text(shortMatkul(tugas.mataKuliah))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        HStack(spacing: 8) {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar").font(.system(size: 9))
                                Text(deadlineText).font(.system(size: 10))
                            }
                            .foregroundColor(deadlineColor)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(deadlineColor.opacity(0.12))
                            .cornerRadius(4)

                            if !tugas.isSelesai {
                                HStack(spacing: 3) {
                                    Image(systemName: tugas.prioritas.icon).font(.system(size: 9))
                                    Text(tugas.prioritas.localizedLabel(isEN: isEN)).font(.system(size: 10))
                                }
                                .foregroundColor(tugas.prioritas.color)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(tugas.prioritas.color.opacity(0.12))
                                .cornerRadius(4)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(cardBackground)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(cardBorder, lineWidth: 1))
        .padding(.horizontal, 20)
        .contextMenu {
            Button(action: onToggle) {
                Label(
                    tugas.isSelesai
                        ? (isEN ? "Mark as Active" : "Tandai Aktif")
                        : (isEN ? "Mark as Done" : "Tandai Selesai"),
                    systemImage: tugas.isSelesai ? "arrow.uturn.left" : "checkmark.circle.fill"
                )
            }
            Button(action: onTap) {
                Label(s.tugasEdit, systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label(isEN ? "Delete Task" : "Hapus Tugas", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label(s.actionDelete, systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onToggle) {
                Label(
                    tugas.isSelesai
                        ? (isEN ? "Reopen" : "Aktifkan")
                        : (isEN ? "Done" : "Selesai"),
                    systemImage: tugas.isSelesai ? "arrow.uturn.left" : "checkmark"
                )
            }
            .tint(tugas.isSelesai ? .orange : .green)
        }
    }

    private var deadlineText: String {
        if tugas.isSelesai {
            let f = DateFormatter()
            f.locale = Locale(identifier: isEN ? "en_US" : "id_ID")
            f.dateFormat = "d MMM"
            return f.string(from: tugas.deadline)
        }
        return tugas.localizedHariSisa(isEN: isEN)
    }

    private var deadlineColor: Color {
        if tugas.isSelesai { return .secondary }
        if tugas.isOverdue { return .red }
        if tugas.isDeadlineSoon { return .orange }
        return .blue
    }

    private var borderColor: Color {
        if tugas.isOverdue { return .red.opacity(0.5) }
        if tugas.isDeadlineSoon { return .orange.opacity(0.5) }
        return .gray.opacity(0.3)
    }

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.15))
            } else {
                RoundedRectangle(cornerRadius: 12).fill(Color.white)
            }
        }
    }

    private var cardBorder: Color {
        if tugas.isSelesai { return .clear }
        if tugas.isOverdue { return .red.opacity(0.2) }
        if tugas.isDeadlineSoon { return .orange.opacity(0.2) }
        return colorScheme == .dark ? Color.white.opacity(0.08) : Color.clear
    }

    private func shortMatkul(_ name: String) -> String {
        if let paren = name.lastIndex(of: "(") {
            return String(name[..<paren]).trimmingCharacters(in: .whitespaces)
        }
        return name
    }
}
