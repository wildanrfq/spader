//
//  CalendarView.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @Environment(\.colorScheme) var colorScheme
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showNoteSheet = false
    
    private let calendar = Calendar.current
    private var daysOfWeek: [String] { let s = languageManager.strings; return [s.dayShortSun, s.dayShortMon, s.dayShortTue, s.dayShortWed, s.dayShortThu, s.dayShortFri, s.dayShortSat] }
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 0) {
                // Month/Year header with navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(colorScheme == .dark ? Color(white: 0.2).opacity(0.7) : Color.white.opacity(0.7))
                
                Divider()
                
                // Calendar Grid
                ScrollView {
                    VStack(spacing: 0) {
                        // Days of week header
                        HStack(spacing: 0) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Text(day)
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color(white: 0.2).opacity(0.5) : Color.white.opacity(0.5))
                        
                        // Calendar days
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                            ForEach(getDaysInMonth(), id: \.self) { date in
                                if let date = date {
                                    DayCell(
                                        date: date,
                                        isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!),
                                        isToday: calendar.isDateInToday(date),
                                        note: scheduleManager.getCalendarNote(for: date),
                                        hasSchedule: hasSchedule(for: date)
                                    )
                                    .onTapGesture {
                                        selectedDate = date
                                        showNoteSheet = true
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 60)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Notes List
                        if !scheduleManager.calendarNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(languageManager.strings.calendarNoteLabel)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                
                                ForEach(getVisibleNotes()) { note in
                                    NoteRow(note: note)
                                        .onTapGesture {
                                            selectedDate = note.date
                                            showNoteSheet = true
                                        }
                                }
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            if let date = selectedDate {
                NoteSheetView(date: date)
                    .environmentObject(scheduleManager)
            }
        }
    }
    
    // MARK: - Helper Methods
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageManager.currentLanguage == "EN" ? "en_US" : "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        var days: [Date?] = []
        
        // Hitung weekday index untuk firstDayOfMonth (1=Sun, 2=Mon, ..., 7=Sat)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Konversi supaya Minggu=0, Senin=1, ..., Sabtu=6 (sesuai grid kamu)
        let emptyDays = (firstWeekday - 1) % 7
        
        // Tambahkan cell kosong
        days.append(contentsOf: Array(repeating: nil, count: emptyDays))
        
        // Tambahkan tanggal bulan ini
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }

    
    private func hasSchedule(for date: Date) -> Bool {
        let dayName = getDayName(for: date)
        return scheduleManager.jadwalList.contains { $0.jadwal.contains(dayName) }
    }
    
    private func getDayName(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let dayMapping = [1: "Minggu", 2: "Senin", 3: "Selasa", 4: "Rabu",
                          5: "Kamis", 6: "Jumat", 7: "Sabtu"]
        return dayMapping[weekday] ?? ""
    }
    
    private func getVisibleNotes() -> [CalendarNote] {
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        return scheduleManager.calendarNotes.filter { note in
            let noteMonth = calendar.component(.month, from: note.date)
            let noteYear = calendar.component(.year, from: note.date)
            return noteMonth == currentMonth && noteYear == currentYear
        }.sorted { $0.date < $1.date }
    }
    
    private func previousMonth() {
        withAnimation {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }
}
