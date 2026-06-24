//
//  NoteSheetView.swift
//  spader
//

import SwiftUI

struct NoteSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var languageManager: LanguageManager

    let date: Date
    @State private var noteText: String = ""
    @State private var selectedColor: Color = .blue

    private let calendar = Calendar.current
    private var s: AppStrings { languageManager.strings }
    private var isEN: Bool { s.navHome == "Home" }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Toolbar
            HStack {
                Button(s.actionCancel) { dismiss() }
                    .foregroundColor(.blue)
                Spacer()
                Text(formattedDate)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button(s.actionSave) {
                    scheduleManager.addOrUpdateCalendarNote(for: date, note: noteText, color: selectedColor)
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(colorScheme == .dark ? Color(white: 0.15) : Color(.systemBackground))
            .overlay(Divider(), alignment: .bottom)

            // MARK: Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Delete button (if note exists)
                    if existingNote != nil {
                        Button(role: .destructive) {
                            scheduleManager.addOrUpdateCalendarNote(for: date, note: "", color: selectedColor)
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Label(isEN ? "Delete Note" : "Hapus Catatan", systemImage: "trash")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(10)
                        }
                    }

                    // Schedule for this day
                    if !schedulesForDay.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(isEN ? "Today's Schedule" : "Jadwal Hari Ini")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)

                            ForEach(schedulesForDay) { jadwal in
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(jadwal.color)
                                        .frame(width: 4, height: 44)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(jadwal.namaMataKuliah)
                                            .font(.subheadline.bold())
                                            .lineLimit(1)
                                        Text(jadwal.jadwal)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                                .cornerRadius(10)
                            }
                        }
                    }

                    // Color Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(s.calendarColorLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(Color.availableColors, id: \.self) { color in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.25)) {
                                            selectedColor = color
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 40, height: 40)
                                            if selectedColor == color {
                                                Circle()
                                                    .strokeBorder(Color.primary, lineWidth: 3)
                                                    .frame(width: 46, height: 46)
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                        }
                    }

                    // Note Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text(s.calendarNoteLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)

                        ZStack(alignment: .topLeading) {
                            if noteText.isEmpty {
                                Text(s.calendarNoteHint)
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 14)
                            }
                            TextEditor(text: $noteText)
                                .frame(minHeight: 120)
                                .padding(8)
                        }
                        .background(colorScheme == .dark ? Color(white: 0.18) : Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(colorScheme == .dark ? Color(white: 0.12) : Color(.systemGroupedBackground))
        .onAppear {
            if let existing = scheduleManager.getCalendarNote(for: date) {
                noteText = existing.note
                selectedColor = existing.color
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: isEN ? "en_US" : "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }

    private var schedulesForDay: [JadwalKuliah] {
        let dayName = getDayName(for: date)
        return scheduleManager.jadwalList.filter { $0.jadwal.contains(dayName) }
    }

    private func getDayName(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        return [1:"Minggu",2:"Senin",3:"Selasa",4:"Rabu",
                5:"Kamis",6:"Jumat",7:"Sabtu"][weekday] ?? ""
    }

    private var existingNote: CalendarNote? {
        scheduleManager.getCalendarNote(for: date)
    }
}
