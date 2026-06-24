// Core/Services/ScheduleParser.swift
import Foundation

class ScheduleParser {
    static let shared = ScheduleParser()
    private init() {}
    
    private let days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]
    private let skipKeywords = ["Kurikulum", "Kode Mata Kuliah", "Nama Mata Kuliah", "Kelas", "SKS", "Jadwal", "Dosen", "Kehadiran", "IF21"]
    
    // MARK: - OCR Text Cleanup (Conservative)
    private func cleanupOCRText(_ text: String) -> String {
        var cleaned = text
        
        // ONLY fix clear OCR errors, DO NOT change Patt.I/II/III based on assumptions
        
        // 1. Fix slash "/" which is clearly an OCR error for "I"
        cleaned = cleaned.replacingOccurrences(of: "Patt./", with: "Patt.I")
        
        // 2. Fix lowercase "l" and "L" variations (OCR confusion)
        // But keep the NUMBER of I's - don't change I to II or vice versa
        cleaned = fixLowercaseIssues(cleaned)
        
        // 3. Fix room number digit confusions
        cleaned = cleaned.replacingOccurrences(of: "-30 ", with: "-3D ")  // 0 → D
        cleaned = cleaned.replacingOccurrences(of: "-38 ", with: "-3B ")  // 8 → B
        cleaned = cleaned.replacingOccurrences(of: "-30\n", with: "-3D\n")
        cleaned = cleaned.replacingOccurrences(of: "-38\n", with: "-3B\n")
        
        // 4. Fix O/0 confusion for "I"
        cleaned = cleaned.replacingOccurrences(of: "Patt.O-", with: "Patt.I-")
        cleaned = cleaned.replacingOccurrences(of: "Patt.0-", with: "Patt.I-")
        
        // 5. Normalize spacing
        cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        
        return cleaned
    }
    
    // MARK: - Fix Lowercase Issues (Conservative)
    private func fixLowercaseIssues(_ text: String) -> String {
        var result = text
        
        // Pattern for single lowercase l → I
        // "Patt.l-" → "Patt.I-"
        result = result.replacingOccurrences(
            of: "Patt\\.l-",
            with: "Patt.I-",
            options: .regularExpression
        )
        
        // Pattern for double lowercase ll → II
        // "Patt.ll-" → "Patt.II-"
        result = result.replacingOccurrences(
            of: "Patt\\.ll-",
            with: "Patt.II-",
            options: .regularExpression
        )
        
        // Pattern for mixed case variations of II
        // "Patt.Il-", "Patt.lI-", "Patt.iI-", "Patt.Ii-" → "Patt.II-"
        let doubleIVariations = ["Il", "lI", "iI", "Ii", "ii"]
        for _ in doubleIVariations {
            result = result.replacingOccurrences(
                of: "Patt\\.\\(variation)-",
                with: "Patt.II-",
                options: .regularExpression
            )
        }
        
        // Pattern for triple lowercase lll → III
        // "Patt.lll-" → "Patt.III-"
        result = result.replacingOccurrences(
            of: "Patt\\.lll-",
            with: "Patt.III-",
            options: .regularExpression
        )
        
        // Pattern for mixed case variations of III
        let tripleIVariations = ["IIl", "IlI", "lII", "Ill", "IIi", "iii"]
        for _ in tripleIVariations {
            result = result.replacingOccurrences(
                of: "Patt\\.\\(variation)-",
                with: "Patt.III-",
                options: .regularExpression
            )
        }
        
        return result
    }
    
    // MARK: - Main Parse Function
    func parseJadwal(from text: String) -> [JadwalKuliah] {
        // Clean up OCR text (conservative - only fix clear errors)
        let cleanedText = cleanupOCRText(text)
        
        let lines = cleanedText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard let idxMatkul = lines.firstIndex(where: { $0.contains("Nama Mata Kuliah") }),
              let idxJadwal = lines.firstIndex(where: { $0.contains("Jadwal") }),
              let idxKehadiran = lines.firstIndex(where: { $0.contains("Kehadiran") })
        else {
            return fallbackParser(from: lines)
        }
        
        let matkulList = extractMataKuliah(from: lines, start: idxMatkul + 1, end: idxJadwal)
        let kelasList = lines.filter { $0.hasPrefix("IF-") }
        
        var combinedData: [String] = []
        for i in (idxJadwal + 1)..<idxKehadiran {
            let line = lines[i]
            if !line.hasPrefix("IF-") {
                combinedData.append(line)
            }
        }
        
        let (jadwalList, dosenList) = extractJadwalAndDosen(from: combinedData)
        
        var result: [JadwalKuliah] = []
        let count = min(matkulList.count, kelasList.count, jadwalList.count, dosenList.count)
        
        for i in 0..<count {
            let namaLengkap = "\(matkulList[i]) (\(kelasList[i]))"
            let jadwalFixed = jadwalList[i].replacingOccurrences(of: "/", with: "I")
            
            result.append(JadwalKuliah(
                namaMataKuliah: namaLengkap,
                jadwal: jadwalFixed,
                dosen: dosenList[i]
            ))
        }
        
        return sortByDayAndTime(result)
    }
    
    // MARK: - Extract Mata Kuliah
    private func extractMataKuliah(from lines: [String], start: Int, end: Int) -> [String] {
        var matkulList: [String] = []
        
        for i in start..<end {
            let line = lines[i]
            
            // Skip unwanted lines
            if line == "IF21" ||
               line.range(of: "^\\d{8,}$", options: .regularExpression) != nil ||
               line == "Kelas" || line == "SKS" ||
               line.range(of: "^\\d{1}$", options: .regularExpression) != nil ||
               line.hasPrefix("IF-") {
                continue
            }
            
            matkulList.append(line)
        }
        
        return matkulList
    }
    
    // MARK: - Extract Jadwal and Dosen
    private func extractJadwalAndDosen(from combinedData: [String]) -> ([String], [String]) {
        var jadwalList: [String] = []
        var dosenList: [String] = []
        
        var i = 0
        while i < combinedData.count {
            var line = removeBullet(combinedData[i])
            let containsDay = days.contains(where: { line.contains($0) })
            
            if containsDay {
                // Check for lab info on next line
                if i + 1 < combinedData.count {
                    let nextLine = removeBullet(combinedData[i + 1])
                    if nextLine.hasPrefix("Laboratorium") {
                        line = "\(line) \(nextLine)"
                        i += 1
                    }
                }
                
                // Try to split jadwal and dosen from same line
                if let splitResult = splitJadwalDosen(line) {
                    jadwalList.append(splitResult.jadwal)
                    dosenList.append(splitResult.dosen)
                } else {
                    jadwalList.append(line)
                    
                    // Extract dosen from following lines
                    if i + 1 < combinedData.count {
                        var dosen = removeBullet(combinedData[i + 1])
                        i += 1
                        
                        // Combine multi-line dosen names
                        while i + 1 < combinedData.count {
                            let nextLine = removeBullet(combinedData[i + 1])
                            let isDayLine = days.contains(where: { nextLine.contains($0) })
                            
                            if !isDayLine &&
                               (nextLine.contains(".") || nextLine.first?.isUppercase == true) &&
                               nextLine.split(separator: " ").count <= 3 {
                                dosen = "\(dosen) \(nextLine)"
                                i += 1
                            } else {
                                break
                            }
                        }
                        
                        dosenList.append(dosen)
                    }
                }
            }
            i += 1
        }
        
        return (jadwalList, dosenList)
    }
    
    // MARK: - Split Jadwal and Dosen
    private func splitJadwalDosen(_ line: String) -> (jadwal: String, dosen: String)? {
        let pattern = "((?:Senin|Selasa|Rabu|Kamis|Jumat|Sabtu|Minggu)[^•]+)•(.+)"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) {
            if let jadwalRange = Range(match.range(at: 1), in: line),
               let dosenRange = Range(match.range(at: 2), in: line) {
                return (
                    jadwal: String(line[jadwalRange]).trimmingCharacters(in: .whitespacesAndNewlines),
                    dosen: String(line[dosenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        }
        return nil
    }
    
    // MARK: - Remove Bullet Points
    private func removeBullet(_ line: String) -> String {
        var s = line.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: "^[•.\\s]+", with: "", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Fallback Parser
    private func fallbackParser(from lines: [String]) -> [JadwalKuliah] {
        var result: [JadwalKuliah] = []
        
        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if line.isEmpty || skipKeywords.contains(where: { line.contains($0) }) {
                i += 1
                continue
            }
            
            if line.range(of: "^\\d{8,}$", options: .regularExpression) != nil {
                i += 1
                continue
            }
            
            let isCourseName = !days.contains(where: { line.contains($0) }) &&
                               !line.hasPrefix("•") &&
                               !line.hasPrefix(".") &&
                               line.count > 5 &&
                               !line.contains(":") &&
                               !(line.contains("S.") && (line.contains("M.") || line.contains("Dr.")))
            
            if isCourseName {
                let namaMataKuliah = line
                var jadwal = ""
                var dosen = ""
                
                var j = i + 1
                while j < min(i + 5, lines.count) {
                    let nextLine = lines[j].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if nextLine.isEmpty {
                        j += 1
                        continue
                    }
                    
                    if days.contains(where: { nextLine.contains($0) }) {
                        jadwal = nextLine.replacingOccurrences(of: "^[•.\\s]+", with: "", options: .regularExpression)
                        j += 1
                        
                        while j < min(i + 8, lines.count) {
                            let dosenLine = lines[j].trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if dosenLine.isEmpty {
                                j += 1
                                continue
                            }
                            
                            if (dosenLine.contains("S.") || dosenLine.contains("M.") || dosenLine.contains("Dr.")) &&
                               !days.contains(where: { dosenLine.contains($0) }) {
                                dosen = dosenLine.replacingOccurrences(of: "^[•.\\s]+", with: "", options: .regularExpression)
                                break
                            }
                            j += 1
                        }
                        break
                    }
                    j += 1
                }
                
                if !jadwal.isEmpty && !dosen.isEmpty {
                    let jadwalFixed = jadwal.replacingOccurrences(of: "/", with: "I")
                    result.append(JadwalKuliah(
                        namaMataKuliah: namaMataKuliah,
                        jadwal: jadwalFixed,
                        dosen: dosen
                    ))
                }
                
                i = j
            } else {
                i += 1
            }
        }
        
        return sortByDayAndTime(result)
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
