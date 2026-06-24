//
//  CourseDetailView.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct CourseDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var scheduleManager: ScheduleManager
    
    let jadwal: JadwalKuliah
    @State private var editedNote: String
    @State private var selectedColor: Color
    
    init(jadwal: JadwalKuliah) {
        self.jadwal = jadwal
        _editedNote = State(initialValue: jadwal.note ?? "")
        _selectedColor = State(initialValue: jadwal.color)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Color indicator
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedColor)
                                .frame(width: 100, height: 8)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        // Course Info
                        VStack(alignment: .leading, spacing: 16) {
                            InfoRow(icon: "book.fill", title: "Mata Kuliah", content: jadwal.namaMataKuliah)
                            InfoRow(icon: "clock.fill", title: "Jadwal", content: jadwal.jadwal)
                            InfoRow(icon: "person.fill", title: "Dosen", content: jadwal.dosen)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Warna")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Color.availableColors, id: \.self) { color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                            .onTapGesture {
                                                withAnimation {
                                                    selectedColor = color
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Catatan")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ZStack(alignment: .topLeading) {
                                if editedNote.isEmpty {
                                    Text("Tambahkan catatan untuk mata kuliah ini...")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $editedNote)
                                    .frame(minHeight: 100)
                                    .padding(4)
                                    .background(colorScheme == .dark ? Color(white: 0.15) : Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        
                        // Quick Actions
                        VStack(spacing: 12) {
                            Button(action: openSpada) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Buka Spada")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Detail Mata Kuliah")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedJadwal = jadwal
        updatedJadwal.note = editedNote.isEmpty ? nil : editedNote
        updatedJadwal.colorHex = selectedColor.toHex()
        scheduleManager.updateJadwal(updatedJadwal)
    }
    
    private func openSpada() {
        if let url = URL(string: "https://spada.upnyk.ac.id/login/index.php") {
            UIApplication.shared.open(url)
        }
    }
}