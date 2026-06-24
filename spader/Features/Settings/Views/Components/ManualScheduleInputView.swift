//
//  ManualScheduleInputView.swift
//  spader
//
//  Features/Settings/Views/Components/ManualScheduleInputView.swift
//

import SwiftUI

struct ManualScheduleInputView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var scheduleManager: ScheduleManager
    
    @State private var courseName: String = ""
    @State private var classCode: String = ""
    @State private var selectedDay: String = "Senin"
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var location: String = ""
    @State private var lecturerName: String = ""
    
    private let days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]
    
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
                                Text("Simpan Jadwal")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .disabled(!isFormValid)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Tambah Jadwal Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !courseName.isEmpty && 
        !classCode.isEmpty && 
        !location.isEmpty && 
        !lecturerName.isEmpty
    }
    
    private func saveSchedule() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let startTimeStr = timeFormatter.string(from: startTime)
        let endTimeStr = timeFormatter.string(from: endTime)
        
        let scheduleText = "\(selectedDay) \(startTimeStr) - \(endTimeStr) \(location)"
        let fullCourseName = "\(courseName) (\(classCode))"
        
        let newSchedule = JadwalKuliah(
            namaMataKuliah: fullCourseName,
            jadwal: scheduleText,
            dosen: lecturerName
        )
        
        scheduleManager.addJadwal(newSchedule)
        
        dismiss()
    }
    
    // Removed duplicate sorting functions - now handled by ScheduleManager
}

#Preview {
    ManualScheduleInputView()
        .environmentObject(ScheduleManager())
}
