import Foundation
import SwiftUI
internal import Combine

// MARK: - ScheduleManager dengan Persistent Storage
class ScheduleManager: ObservableObject {
    @Published var jadwalList: [JadwalKuliah] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    @Published var calendarNotes: [CalendarNote] = [] {
        didSet {
            saveCalendarNotes()
        }
    }
    
    private let userDefaultsKey = "savedJadwalList"
    private let calendarNotesKey = "savedCalendarNotes"
    private let appGroup = "group.com.wildanrfq.spader"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }
    
    init() {
        loadFromUserDefaults()
        loadCalendarNotes()
    }
    
    // MARK: - Jadwal Methods
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(jadwalList)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            
            // Also save to App Group for widget
            sharedDefaults?.set(data, forKey: userDefaultsKey)
            
            print("✅ Jadwal berhasil disimpan (\(jadwalList.count) items)")
        } catch {
            print("❌ Error saving jadwal: \(error.localizedDescription)")
        }
    }
    
    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("ℹ️ Tidak ada jadwal tersimpan")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            jadwalList = try decoder.decode([JadwalKuliah].self, from: data)
            print("✅ Jadwal berhasil dimuat (\(jadwalList.count) items)")
        } catch {
            print("❌ Error loading jadwal: \(error.localizedDescription)")
        }
    }
    
    func updateJadwal(_ jadwal: JadwalKuliah) {
        if let index = jadwalList.firstIndex(where: { $0.id == jadwal.id }) {
            jadwalList[index] = jadwal
        }
    }
    
    // MARK: - Add and Sort
    func addJadwal(_ jadwal: JadwalKuliah) {
        jadwalList.append(jadwal)
        sortJadwal()
    }
    
    func sortJadwal() {
        jadwalList = sortByDayAndTime(jadwalList)
    }
    
    // MARK: - Sorting Logic
    private func sortByDayAndTime(_ jadwalList: [JadwalKuliah]) -> [JadwalKuliah] {
        let dayOrder = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]
        
        return jadwalList.sorted { jadwal1, jadwal2 in
            var day1Index = 99
            var day2Index = 99
            
            for (index, day) in dayOrder.enumerated() {
                if jadwal1.jadwal.contains(day) { day1Index = index }
                if jadwal2.jadwal.contains(day) { day2Index = index }
            }
            
            if day1Index != day2Index {
                return day1Index < day2Index
            }
            
            return extractTimeInMinutes(from: jadwal1.jadwal) < extractTimeInMinutes(from: jadwal2.jadwal)
        }
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
    
    // MARK: - Calendar Notes Methods
    private func saveCalendarNotes() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(calendarNotes)
            UserDefaults.standard.set(data, forKey: calendarNotesKey)
        } catch {
            print("❌ Error saving calendar notes: \(error.localizedDescription)")
        }
    }
    
    private func loadCalendarNotes() {
        guard let data = UserDefaults.standard.data(forKey: calendarNotesKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            calendarNotes = try decoder.decode([CalendarNote].self, from: data)
        } catch {
            print("❌ Error loading calendar notes: \(error.localizedDescription)")
        }
    }
    
    func addOrUpdateCalendarNote(for date: Date, note: String, color: Color) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        if let index = calendarNotes.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: normalizedDate)
        }) {
            if note.isEmpty {
                calendarNotes.remove(at: index)
            } else {
                calendarNotes[index].note = note
                calendarNotes[index].colorHex = color.toHex()
            }
        } else if !note.isEmpty {
            calendarNotes.append(CalendarNote(date: normalizedDate, note: note, colorHex: color.toHex()))
        }
    }
    
    func getCalendarNote(for date: Date) -> CalendarNote? {
        let calendar = Calendar.current
        return calendarNotes.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Clear All
    func clearAll() {
        jadwalList.removeAll()
        calendarNotes.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: calendarNotesKey)
        print("🗑️ Semua jadwal dan notes dihapus")
    }
}
