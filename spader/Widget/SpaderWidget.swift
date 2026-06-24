//
//  SpaderWidget.swift
//  SpaderWidget
//
//  Widget/SpaderWidget.swift
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct ScheduleEntry: TimelineEntry {
    let date: Date
    let schedules: [JadwalKuliah]
}

// MARK: - Widget Provider
struct ScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), schedules: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        let entry = ScheduleEntry(date: Date(), schedules: loadSchedules())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        let currentDate = Date()
        let schedules = loadSchedules()
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = ScheduleEntry(date: currentDate, schedules: schedules)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadSchedules() -> [JadwalKuliah] {
        guard let data = UserDefaults(suiteName: "group.com.wildanrfq.spader")?.data(forKey: "savedJadwalList"),
              let schedules = try? JSONDecoder().decode([JadwalKuliah].self, from: data) else {
            return []
        }
        
        // Filter for today's schedules
        let today = getCurrentDay()
        return schedules.filter { $0.jadwal.contains(today) }
            .sorted { extractTimeInMinutes(from: $0.jadwal) < extractTimeInMinutes(from: $1.jadwal) }
    }
    
    private func getCurrentDay() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let dayMapping = [1: "Minggu", 2: "Senin", 3: "Selasa", 4: "Rabu",
                          5: "Kamis", 6: "Jumat", 7: "Sabtu"]
        return dayMapping[weekday] ?? "Senin"
    }
    
    private func extractTimeInMinutes(from schedule: String) -> Int {
        if let range = schedule.range(of: "(\\d{1,2}):(\\d{2})", options: .regularExpression) {
            let timeStr = String(schedule[range])
            let components = timeStr.split(separator: ":")
            if components.count == 2,
               let hour = Int(components[0]),
               let minute = Int(components[1]) {
                return hour * 60 + minute
            }
        }
        return 9999
    }
}

// MARK: - Widget View
struct SpaderWidgetEntryView: View {
    var entry: ScheduleProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        if widgetFamily == .accessoryRectangular {
            LockScreenWidgetView(entry: entry)
        } else {
            HomeScreenWidgetView(entry: entry, isSmall: widgetFamily == .systemSmall)
        }
    }
}

// MARK: - Lock Screen Widget (super minimal)
struct LockScreenWidgetView: View {
    let entry: ScheduleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entry.schedules.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 10))
                    Text("Tidak ada jadwal hari ini")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)
            } else {
                ForEach(entry.schedules.prefix(3)) { schedule in
                    HStack(spacing: 3) {
                        Text(extractStartTime(from: schedule.jadwal))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, alignment: .leading)
                        
                        Text(shortCourseName(schedule.namaMataKuliah))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.vertical, 1)
                }
                
                if entry.schedules.count > 3 {
                    Text("+\(entry.schedules.count - 3) lainnya")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Color.blue
        }
    }
    
    // Only "HH:MM"
    private func extractStartTime(from schedule: String) -> String {
        let pattern = "(\\d{1,2}:\\d{2})\\s*-"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: schedule, range: NSRange(schedule.startIndex..., in: schedule)),
           let range = Range(match.range(at: 1), in: schedule) {
            return String(schedule[range])
        }
        return ""
    }
    
    // Strip class code like "(IF-A)" from end
    private func shortCourseName(_ name: String) -> String {
        if let paren = name.lastIndex(of: "(") {
            return String(name[..<paren]).trimmingCharacters(in: .whitespaces)
        }
        return name
    }
}

// MARK: - Home Screen Widget (small & medium)
struct HomeScreenWidgetView: View {
    let entry: ScheduleEntry
    let isSmall: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: isSmall ? 3 : 4) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: isSmall ? 11 : 12))
                Text("Jadwal Hari Ini")
                    .font(.system(size: isSmall ? 11 : 12, weight: .semibold))
                Spacer()
            }
            .foregroundColor(.white)
            
            if entry.schedules.isEmpty {
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: isSmall ? 24 : 28))
                    Text("Tidak ada jadwal")
                        .font(.system(size: 9))
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white.opacity(0.8))
                Spacer()
            } else {
                VStack(spacing: isSmall ? 3 : 4) {
                    ForEach(entry.schedules.prefix(isSmall ? 1 : 3)) { schedule in
                        ScheduleRowWidget(schedule: schedule, isSmall: isSmall)
                    }
                }
                
                if entry.schedules.count > (isSmall ? 1 : 3) {
                    Text("+\(entry.schedules.count - (isSmall ? 1 : 3)) lainnya")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 1)
                }
                
                Spacer(minLength: 0)
            }
        }
        .padding(isSmall ? 10 : 12)
        .containerBackground(for: .widget) {
            Color.blue
        }
    }
}

struct ScheduleRowWidget: View {
    let schedule: JadwalKuliah
    let isSmall: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Course name - truncate properly
            Text(schedule.namaMataKuliah)
                .font(.system(size: isSmall ? 10 : 11, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Time and location - super compact
            HStack(spacing: 4) {
                // Time
                HStack(spacing: 2) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: isSmall ? 7 : 8))
                    Text(extractTime(from: schedule.jadwal))
                        .font(.system(size: isSmall ? 8 : 9))
                }
                
                // Location
                HStack(spacing: 2) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: isSmall ? 7 : 8))
                    Text(extractLocation(from: schedule.jadwal))
                        .font(.system(size: isSmall ? 8 : 9))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .foregroundColor(.white.opacity(0.95))
        }
        .padding(.horizontal, isSmall ? 5 : 6)
        .padding(.vertical, isSmall ? 4 : 5)
        .background(Color.white.opacity(0.2))
        .cornerRadius(5)
    }
    
    private func extractTime(from schedule: String) -> String {
        // Pattern untuk mengambil waktu pertama saja (HH:MM - HH:MM)
        if let range = schedule.range(of: "\\d{1,2}:\\d{2}\\s*-\\s*\\d{1,2}:\\d{2}", options: .regularExpression) {
            return String(schedule[range])
        }
        return ""
    }
    
    private func extractLocation(from schedule: String) -> String {
        // Remove day name first (Senin, Selasa, etc.)
        var cleaned = schedule
        let days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]
        for day in days {
            cleaned = cleaned.replacingOccurrences(of: day, with: "")
        }
        
        // Remove all time patterns (to handle duplicates)
        // This removes ALL occurrences of time patterns
        let timePattern = "\\d{1,2}:\\d{2}\\s*-\\s*\\d{1,2}:\\d{2}"
        if let regex = try? NSRegularExpression(pattern: timePattern, options: []) {
            let range = NSRange(cleaned.startIndex..., in: cleaned)
            cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
        }
        
        // Also remove standalone times like "- 12:30"
        cleaned = cleaned.replacingOccurrences(of: "-\\s*\\d{1,2}:\\d{2}", with: "", options: .regularExpression)
        
        // Clean up extra spaces and dashes
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "^-\\s*", with: "", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}

// MARK: - Widget Configuration
struct SpaderWidget: Widget {
    let kind: String = "SpaderWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleProvider()) { entry in
            SpaderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Jadwal Kuliah")
        .description("Lihat jadwal kuliah hari ini")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
        // Optional: This allows your background to fill the entire widget area
        .contentMarginsDisabled()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    SpaderWidget()
} timeline: {
    ScheduleEntry(date: Date(), schedules: [
        JadwalKuliah(namaMataKuliah: "Basis Data (IF-A1)", jadwal: "Senin 10:00 - 12:00 Patt.I-3A", dosen: "Dr. Test"),
        JadwalKuliah(namaMataKuliah: "Algoritma (IF-B2)", jadwal: "Senin 13:00 - 15:00 Patt.II-3B", dosen: "Dr. Test2")
    ])
}

#Preview(as: .systemMedium) {
    SpaderWidget()
} timeline: {
    ScheduleEntry(date: Date(), schedules: [
        JadwalKuliah(namaMataKuliah: "Basis Data (IF-A1)", jadwal: "Senin 10:00 - 12:00 Patt.I-3A", dosen: "Dr. Test"),
        JadwalKuliah(namaMataKuliah: "Algoritma (IF-B2)", jadwal: "Senin 13:00 - 15:00 Patt.II-3B", dosen: "Dr. Test2")
    ])
}

#Preview(as: .accessoryRectangular) {
    SpaderWidget()
} timeline: {
    ScheduleEntry(date: Date(), schedules: [
        JadwalKuliah(namaMataKuliah: "Basis Data (IF-A1)", jadwal: "Senin 10:00 - 12:00 Patt.I-3A", dosen: "Dr. Test")
    ])
}
