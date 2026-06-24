//
//  AddEditTugasView.swift
//  spader
//

import SwiftUI

struct AddEditTugasView: View {
    @EnvironmentObject var languageManager: LanguageManager
    enum Mode { case add; case edit(Tugas) }

    let mode: Mode
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var tugasManager: TugasManager
    @EnvironmentObject var scheduleManager: ScheduleManager

    @State private var judul = ""
    @State private var deskripsi = ""
    @State private var selectedMatkulName = ""
    @State private var manualMatkul = ""
    @State private var useManualMatkul = false
    @State private var deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var prioritas: TugasPrioritas = .sedang
    @State private var showJudulError = false
    @State private var showMatkulError = false

    private var s: AppStrings { languageManager.strings }
    private var isEN: Bool { s.navHome == "Home" }

    private var isEdit: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var existingTugas: Tugas? {
        if case .edit(let t) = mode { return t }
        return nil
    }

    private var matkulList: [JadwalKuliah] {
        var seen = Set<String>()
        return scheduleManager.jadwalList.filter { seen.insert($0.namaMataKuliah).inserted }
    }

    private func shortName(_ name: String) -> String {
        if let paren = name.lastIndex(of: "(") {
            return String(name[..<paren]).trimmingCharacters(in: .whitespaces)
        }
        return name
    }

    private var selectedMatkulColor: String {
        matkulList.first(where: { $0.namaMataKuliah == selectedMatkulName })?.colorHex ?? "007AFF"
    }

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        titleSection
                        courseSection
                        deadlineSection
                        prioritySection
                        notesSection
                        saveButton
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                }
            }
            .navigationTitle(isEdit ? s.tugasEdit : s.tugasAdd)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.actionCancel) { dismiss() }
                }
            }
            .onAppear { prefill() }
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        formSection(title: s.tugasTitle2) {
            VStack(alignment: .leading, spacing: 6) {
                TextField(
                    isEN ? "e.g. Midterm Exam, Lab Report..." : "Contoh: UTS Basis Data, Laporan Praktikum...",
                    text: $judul
                )
                .font(.body).padding(12).background(fieldBg).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(showJudulError ? Color.red : Color.clear, lineWidth: 1.5))
                .onChange(of: judul) { _ in showJudulError = false }

                if showJudulError {
                    Text(isEN ? "Title cannot be empty" : "Judul tidak boleh kosong")
                        .font(.caption).foregroundColor(.red)
                }
            }
        }
    }

    private var courseSection: some View {
        formSection(title: s.tugasCourse) {
            VStack(alignment: .leading, spacing: 10) {
                if !matkulList.isEmpty && !useManualMatkul {
                    dropdownPicker
                }

                if !matkulList.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            useManualMatkul.toggle()
                            if useManualMatkul { selectedMatkulName = "" }
                            else { manualMatkul = "" }
                            showMatkulError = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: useManualMatkul ? "arrow.left.circle" : "pencil.circle")
                                .font(.caption)
                            Text(useManualMatkul
                                ? (isEN ? "Back to list" : "Kembali ke pilihan")
                                : (isEN ? "Type manually" : "Input nama manual"))
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if useManualMatkul || matkulList.isEmpty {
                    TextField(
                        isEN ? "Course name" : "Nama mata kuliah",
                        text: $manualMatkul
                    )
                    .font(.body).padding(12).background(fieldBg).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(showMatkulError ? Color.red : Color.clear, lineWidth: 1.5))
                    .onChange(of: manualMatkul) { _ in showMatkulError = false }
                }

                if showMatkulError {
                    Text(isEN ? "Please select or enter a course" : "Pilih atau masukkan mata kuliah")
                        .font(.caption).foregroundColor(.red)
                }
            }
        }
    }

    private var dropdownPicker: some View {
        Menu {
            Button(action: { selectedMatkulName = "" }) {
                Label(isEN ? "Select course..." : "Pilih mata kuliah...", systemImage: "minus.circle")
            }
            Divider()
            ForEach(matkulList) { matkul in
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    selectedMatkulName = matkul.namaMataKuliah
                    showMatkulError = false
                }) {
                    Label(shortName(matkul.namaMataKuliah), systemImage: "book.fill")
                }
            }
        } label: {
            HStack {
                if !selectedMatkulName.isEmpty {
                    Circle()
                        .fill(Color(hex: selectedMatkulColor))
                        .frame(width: 10, height: 10)
                    Text(shortName(selectedMatkulName))
                        .font(.body).foregroundColor(.primary).lineLimit(1)
                } else {
                    Text(isEN ? "Select course..." : "Pilih mata kuliah...")
                        .font(.body).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13)).foregroundColor(.secondary)
            }
            .padding(12)
            .background(showMatkulError ? Color.red.opacity(0.08) : fieldBg)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(showMatkulError ? Color.red : Color.clear, lineWidth: 1.5))
        }
    }

    private var deadlineSection: some View {
        formSection(title: s.tugasDeadline) {
            DatePicker(
                isEN ? "Select date & time" : "Pilih tanggal & waktu",
                selection: $deadline,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(.blue)
            .padding(4)
            .environment(\.locale, Locale(identifier: isEN ? "en_US" : "id_ID"))
        }
    }

    private var prioritySection: some View {
        formSection(title: s.tugasPriority) {
            HStack(spacing: 10) {
                ForEach(TugasPrioritas.allCases, id: \.self) { p in
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        prioritas = p
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: p.icon).font(.system(size: 13))
                            Text(p.localizedLabel(isEN: isEN)).font(.subheadline.weight(.medium))
                        }
                        .foregroundColor(prioritas == p ? .white : p.color)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(prioritas == p ? p.color : p.color.opacity(0.12))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var notesSection: some View {
        formSection(title: isEN ? "Notes (optional)" : "Catatan (opsional)") {
            ZStack(alignment: .topLeading) {
                if deskripsi.isEmpty {
                    Text(isEN ? "Add notes, task details..." : "Tambahkan catatan, detail tugas...")
                        .font(.body).foregroundColor(.secondary.opacity(0.7)).padding(12)
                }
                TextEditor(text: $deskripsi)
                    .frame(minHeight: 80).padding(8)
                    .background(fieldBg).cornerRadius(10)
            }
            .background(fieldBg).cornerRadius(10)
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text(isEdit ? s.actionSave : s.tugasAdd)
                .font(.headline).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding()
                .background(Color.blue).cornerRadius(14)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 4).padding(.bottom, 30)
    }

    // MARK: - Helpers

    private var fieldBg: Color {
        colorScheme == .dark ? Color(white: 0.18) : Color(white: 0.95)
    }

    @ViewBuilder
    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundColor(.primary)
            content()
        }
        .padding(14)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func prefill() {
        guard let t = existingTugas else { return }
        judul = t.judul
        deskripsi = t.deskripsi
        deadline = t.deadline
        prioritas = t.prioritas
        if matkulList.first(where: { $0.namaMataKuliah == t.mataKuliah }) != nil {
            selectedMatkulName = t.mataKuliah
            useManualMatkul = false
        } else {
            manualMatkul = t.mataKuliah
            useManualMatkul = true
        }
    }

    private func save() {
        let trimmedJudul = judul.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedJudul.isEmpty else {
            showJudulError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        let matkulName: String
        let matkulColor: String
        if useManualMatkul || matkulList.isEmpty {
            let trimmed = manualMatkul.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                showMatkulError = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            matkulName = trimmed
            matkulColor = "007AFF"
        } else {
            guard !selectedMatkulName.isEmpty else {
                showMatkulError = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            matkulName = selectedMatkulName
            matkulColor = selectedMatkulColor
        }

        let tugas = Tugas(
            id: existingTugas?.id ?? UUID(),
            judul: trimmedJudul,
            deskripsi: deskripsi,
            mataKuliah: matkulName,
            mataKuliahColorHex: matkulColor,
            deadline: deadline,
            prioritas: prioritas,
            isSelesai: existingTugas?.isSelesai ?? false,
            createdAt: existingTugas?.createdAt ?? Date()
        )

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if isEdit { tugasManager.update(tugas) } else { tugasManager.tambah(tugas) }
        dismiss()
    }
}
