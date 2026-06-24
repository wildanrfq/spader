//
//  EditScheduleView.swift
//  spader
//
//  Features/Settings/Views/Components/EditScheduleView.swift
//

import SwiftUI

struct EditScheduleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var scheduleManager: ScheduleManager
    
    let jadwal: JadwalKuliah
    
    @State private var courseName: String = ""
    @State private var classCode: String = ""
    @State private var selectedDay: String = "Senin"
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var location: String = ""
    @State private var lecturerName: String = ""
    
    private let days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]
    
    init(jadwal: JadwalKuliah) {
        self.jadwal = jadwal
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                Form {
                    Section(header: Text("Informasi Mata Kuliah")) {
                        TextField("Nama Mata Kuliah", text: $courseName)
                        TextField("Kode Kelas (contoh: IF-A1)", text: $classCode)
                            .autocapitalization(.allCharacters)
                    }
                    
                    Section(header: Text("Jadwal")) {
                        Picker("Hari", selection: $selectedDay) {
                            ForEach(days, id: \.self) { day in
                                Text(day).tag(day)
                            }
                        }
                        
                        DatePicker("Jam Mulai", selection: $startTime, displayedComponents: .hourAndMinute)
                            .environment(\.locale, Locale(identifier: "en_GB"))
                        
                        DatePicker("Jam Selesai", selection: $endTime, displayedComponents: .hourAndMinute)
                            .environment(\.locale, Locale(identifier: "en_GB"))
                        
                        TextField("Lokasi (contoh: Patt.I-3A)", text: $location)
                    }
                    
                    Section(header: Text("Dosen")) {
                        TextField("Nama Dosen (beserta gelar)", text: $lecturerName)
                    }
                    
                    Section {
                        Button(action: saveSchedule) {
                            HStack {
                                Spacer()
                                Text("Simpan Perubahan")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .disabled(!isFormValid)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Jadwal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadScheduleData()
            }
        }
    }
    
    private var isFormValid: Bool {
        !courseName.isEmpty && 
        !classCode.isEmpty && 
        !location.isEmpty && 
        !lecturerName.isEmpty
    }
    
    private func loadScheduleData() {
        // Parse course name and class code from namaMataKuliah
        // Format: "Course Name (IF-A1)"
        if let openParen = jadwal.namaMataKuliah.lastIndex(of: "("),
           let closeParen = jadwal.namaMataKuliah.lastIndex(of: ")") {
            courseName = String(jadwal.namaMataKuliah[..<openParen]).trimmingCharacters(in: .whitespaces)
            let classStart = jadwal.namaMataKuliah.index(after: openParen)
            classCode = String(jadwal.namaMataKuliah[classStart..<closeParen])
        } else {
            courseName = jadwal.namaMataKuliah
            classCode = ""
        }
        
        // Parse day
        for day in days {
            if jadwal.jadwal.contains(day) {
                selectedDay = day
                break
            }
        }
        
        // Parse time
        if let timeRange = jadwal.jadwal.range(of: "\\d{1,2}:\\d{2}\\s*-\\s*\\d{1,2}:\\d{2}", options: .regularExpression) {
            let timeStr = String(jadwal.jadwal[timeRange])
            let times = timeStr.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
            
            if times.count == 2 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                if let start = dateFormatter.date(from: times[0]) {
                    startTime = start
                }
                if let end = dateFormatter.date(from: times[1]) {
                    endTime = end
                }
            }
        }
        
        // Parse location
        let scheduleComponents = jadwal.jadwal.components(separatedBy: " ")
        if let timeEndIndex = scheduleComponents.firstIndex(where: { $0.contains(":") && $0.split(separator: ":").count == 2 }) {
            // Location is everything after the time
            let locationComponents = scheduleComponents[(timeEndIndex + 1)...]
            location = locationComponents.joined(separator: " ")
        }
        
        lecturerName = jadwal.dosen
    }
    
    private func saveSchedule() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let startTimeStr = timeFormatter.string(from: startTime)
        let endTimeStr = timeFormatter.string(from: endTime)
        
        let scheduleText = "\(selectedDay) \(startTimeStr) - \(endTimeStr) \(location)"
        let fullCourseName = "\(courseName) (\(classCode))"
        
        let updatedSchedule = JadwalKuliah(
            id: jadwal.id,
            namaMataKuliah: fullCourseName,
            jadwal: scheduleText,
            dosen: lecturerName,
            note: jadwal.note,
            colorHex: jadwal.colorHex
        )
        
        scheduleManager.updateJadwal(updatedSchedule)
        scheduleManager.sortJadwal()
        
        dismiss()
    }
}

#Preview {
    EditScheduleView(jadwal: JadwalKuliah(
        namaMataKuliah: "Test Course (IF-A1)",
        jadwal: "Senin 10:00 - 12:00 Patt.I-3A",
        dosen: "Test Lecturer S.Si., M.T."
    ))
    .environmentObject(ScheduleManager())
}
