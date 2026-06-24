// Core/Services/StorageService.swift
import Foundation

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    // MARK: - Jadwal Storage
    func saveJadwal(_ jadwalList: [JadwalKuliah]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(jadwalList)
            UserDefaults.standard.set(data, forKey: "savedJadwalList")
            print("✅ Jadwal berhasil disimpan (\(jadwalList.count) items)")
        } catch {
            print("❌ Error saving jadwal: \(error.localizedDescription)")
        }
    }
    
    func loadJadwal() -> [JadwalKuliah] {
        guard let data = UserDefaults.standard.data(forKey: "savedJadwalList") else {
            print("ℹ️ Tidak ada jadwal tersimpan")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let jadwalList = try decoder.decode([JadwalKuliah].self, from: data)
            print("✅ Jadwal berhasil dimuat (\(jadwalList.count) items)")
            return jadwalList
        } catch {
            print("❌ Error loading jadwal: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Calendar Notes Storage
    func saveCalendarNotes(_ notes: [CalendarNote]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)
            UserDefaults.standard.set(data, forKey: "savedCalendarNotes")
        } catch {
            print("❌ Error saving calendar notes: \(error.localizedDescription)")
        }
    }
    
    func loadCalendarNotes() -> [CalendarNote] {
        guard let data = UserDefaults.standard.data(forKey: "savedCalendarNotes") else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([CalendarNote].self, from: data)
        } catch {
            print("❌ Error loading calendar notes: \(error.localizedDescription)")
            return []
        }
    }
    
    // ✅ TAMBAHKAN: OCR Text Storage
    func saveExtractedText(_ text: String) {
        UserDefaults.standard.set(text, forKey: "extractedOCRText")
    }
    
    func loadExtractedText() -> String? {
        return UserDefaults.standard.string(forKey: "extractedOCRText")
    }
    
    func hasExtractedText() -> Bool {
        return loadExtractedText() != nil && !loadExtractedText()!.isEmpty
    }
    
    // MARK: - Clear All
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: "savedJadwalList")
        UserDefaults.standard.removeObject(forKey: "savedCalendarNotes")
        UserDefaults.standard.removeObject(forKey: "extractedOCRText") // ✅ Clear OCR text
        print("🗑️ Semua data dihapus")
    }
}
