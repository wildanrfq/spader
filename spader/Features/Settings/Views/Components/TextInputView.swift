//
//  TextInputView.swift
//  spader
//
//  Features/Settings/Views/Components/TextInputView.swift
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var scheduleManager: ScheduleManager
    @FocusState private var isTextEditorFocused: Bool
    
    @State private var inputText: String = ""
    @State private var showToast = false
    @State private var showErrorAlert = false
    @State private var parsedCount = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Instructions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cara Menggunakan:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("1. Salin (copy) seluruh teks jadwal kuliah kamu dari tabel")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("2. Tempel (paste) di kolom di bawah ini")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("3. Tekan 'Import Jadwal'")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Format yang diharapkan:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            
                            Text("IF21   123210311   Praktikum Sistem...\nSenin 13:00 - 15:00 Patt.I-3A\nDosen Name S.Si., M.T.\n0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                        }
                        .padding()
                        .background(Color(.systemBackground).opacity(0.7))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Text Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tempel Jadwal Kamu:")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            TextEditor(text: $inputText)
                                .focused($isTextEditorFocused)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                        }
                        
                        // Import Button
                        Button(action: {
                            isTextEditorFocused = false
                            importSchedule()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Import Jadwal")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(inputText.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(15)
                            .shadow(color: inputText.isEmpty ? .clear : .blue.opacity(0.3), radius: 4, x: 0, y: 3)
                        }
                        .disabled(inputText.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Import Teks Jadwal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Selesai") {
                            isTextEditorFocused = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert("Gagal Import", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Tidak dapat memparse jadwal. Pastikan format teks sesuai dengan contoh.")
            }
            .toast(isShowing: $showToast, message: "Berhasil mengimport \(parsedCount) jadwal!", icon: "checkmark.circle.fill")
        }
    }
    
    private func importSchedule() {
        let parsed = TextInputParser.shared.parseScheduleText(inputText)
        
        if parsed.isEmpty {
            showErrorAlert = true
        } else {
            parsedCount = parsed.count
            scheduleManager.jadwalList = parsed
            showToast = true
            
            // Auto dismiss after showing toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }
        }
    }
}

#Preview {
    TextInputView()
        .environmentObject(ScheduleManager())
}
