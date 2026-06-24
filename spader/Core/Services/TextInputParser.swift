// Core/Services/TextInputParser.swift
import Foundation

class TextInputParser {
    static let shared = TextInputParser()
    private init() {}
    
    func parseScheduleText(_ text: String) -> [JadwalKuliah] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        var schedules: [JadwalKuliah] = []
        var i = 0
        
        // Skip header lines
        while i < lines.count {
            let line = lines[i]
            if line.contains("Kehadiran") {
                i += 1
                break
            }
            i += 1
        }
        
        // Parse schedule entries (each entry spans 4 lines)
        while i < lines.count {
            if let schedule = parseScheduleEntry(lines: lines, startIndex: i) {
                schedules.append(schedule)
                i += 4 // Move to next entry (4 lines per entry)
            } else {
                i += 1 // Move forward if parsing failed
            }
        }
        
        return sortByDayAndTime(schedules)
    }
    
    private func parseScheduleEntry(lines: [String], startIndex: Int) -> JadwalKuliah? {
        guard startIndex + 3 < lines.count else {
            return nil
        }
        
        // Line 1: IF21\t123210311\tCourse Name\tIF-A\t1\t
        let line1 = lines[startIndex]
        
        // Line 2: Schedule (Day Time - Time Location)
        let line2 = lines[startIndex + 1]
        
        // Line 3: Lecturer name
        let line3 = lines[startIndex + 2]
        
        // Line 4: Attendance number (0)
        // We skip this line
        
        // Skip empty lines
        if line1.isEmpty || line2.isEmpty || line3.isEmpty {
            return nil
        }
        
        // Skip if line1 doesn't start with IF21
        if !line1.hasPrefix("IF21") {
            return nil
        }
        
        // Parse line 1 (tab-separated: IF21, code, course name, class, SKS)
        let components = line1.components(separatedBy: "\t")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard components.count >= 4 else {
            return nil
        }
        
        // Extract course name and class code
        let courseName = components[2] // Third component is course name
        let classCode = components[3]  // Fourth component is class code
        
        // Parse line 2 (schedule)
        let scheduleText = line2.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse line 3 (lecturer)
        let lecturerName = line3.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Combine course name and class code
        let fullCourseName = "\(courseName) (\(classCode))"
        
        return JadwalKuliah(
            namaMataKuliah: fullCourseName,
            jadwal: scheduleText,
            dosen: lecturerName
        )
    }
    
    // MARK: - Sort by Day and Time
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
}
