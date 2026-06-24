//
//  ManageScheduleView.swift
//  spader
//

import SwiftUI

struct ManageScheduleView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var scheduleManager: ScheduleManager
    @Environment(\.dismiss) var dismiss

    @State private var showTextInput = false
    @State private var showManualInput = false
    @State private var showDeleteAlert = false
    @State private var scheduleToDelete: JadwalKuliah?
    @State private var showDeleteAllAlert = false
    @State private var showEditSchedule = false
    @State private var scheduleToEdit: JadwalKuliah?

    private var s: AppStrings { languageManager.strings }
    private var isEN: Bool { s.navHome == "Home" }

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        statusCard
                        importSection
                        if !scheduleManager.jadwalList.isEmpty {
                            deleteAllSection
                            scheduleListSection
                        } else {
                            emptyState
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle(s.manageScheduleTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(s.actionClose) { dismiss() }
                }
            }
            .sheet(isPresented: $showTextInput) {
                TextInputView()
                    .environmentObject(scheduleManager)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showManualInput) {
                ManualScheduleInputView()
                    .environmentObject(scheduleManager)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showEditSchedule) {
                if let jadwal = scheduleToEdit {
                    EditScheduleView(jadwal: jadwal)
                        .environmentObject(scheduleManager)
                        .environmentObject(languageManager)
                }
            }
            .alert(isEN ? "Delete Schedule?" : "Hapus Jadwal?", isPresented: $showDeleteAlert) {
                Button(s.actionCancel, role: .cancel) {}
                Button(s.actionDelete, role: .destructive) {
                    if let j = scheduleToDelete { deleteSchedule(j) }
                }
            } message: {
                if let j = scheduleToDelete {
                    Text(isEN
                        ? "Are you sure you want to delete \(j.namaMataKuliah)?"
                        : "Apakah Anda yakin ingin menghapus \(j.namaMataKuliah)?")
                }
            }
            .alert(isEN ? "Delete All Schedules?" : "Hapus Semua Jadwal?", isPresented: $showDeleteAllAlert) {
                Button(s.actionCancel, role: .cancel) {}
                Button(s.actionDeleteAll, role: .destructive) {
                    scheduleManager.clearAll()
                }
            } message: {
                Text(isEN
                    ? "All imported schedules will be deleted."
                    : "Semua jadwal yang sudah diimport akan dihapus.")
            }
        }
    }

    // MARK: - Sub Views

    private var statusCard: some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .font(.title2).foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(isEN ? "Total Schedules" : "Total Jadwal")
                    .font(.subheadline).foregroundColor(.secondary)
                Text("\(scheduleManager.jadwalList.count) \(isEN ? "Courses" : "Mata Kuliah")")
                    .font(.title3).fontWeight(.semibold)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.7))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private var importSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isEN ? "Add Schedule" : "Tambah Jadwal")
                .font(.headline).foregroundColor(.primary)
                .padding(.horizontal, 20)

            VStack(spacing: 12) {
                Button(action: { showTextInput = true }) {
                    HStack {
                        Image(systemName: "doc.text.fill").font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isEN ? "Import Schedule Text" : "Import Teks Jadwal")
                                .font(.headline)
                            Text(isEN ? "Copy and paste schedule from table" : "Salin dan tempel jadwal dari tabel")
                                .font(.caption).foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white).padding()
                    .background(Color.blue).cornerRadius(12)
                }

                Button(action: { showManualInput = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill").font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isEN ? "Add Manually" : "Tambah Manual")
                                .font(.headline)
                            Text(isEN ? "Input schedule one by one" : "Input jadwal satu per satu")
                                .font(.caption).foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white).padding()
                    .background(Color.green).cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var deleteAllSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(s.manageScheduleTitle)
                .font(.headline).foregroundColor(.primary)
                .padding(.horizontal, 20)

            Button(action: { showDeleteAllAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text(isEN ? "Delete All Schedules" : "Hapus Semua Jadwal")
                    Spacer()
                }
                .font(.headline).foregroundColor(.white).padding()
                .background(Color.red).cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
    }

    private var scheduleListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(isEN ? "Schedule List" : "Daftar Jadwal") (\(scheduleManager.jadwalList.count))")
                .font(.headline).foregroundColor(.primary)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(
                    groupedSchedules.keys.sorted {
                        (dayOrder.firstIndex(of: $0) ?? 99) < (dayOrder.firstIndex(of: $1) ?? 99)
                    },
                    id: \.self
                ) { day in
                    let displayDay = localizedDay(day)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(displayDay)
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        ForEach(groupedSchedules[day] ?? []) { jadwal in
                            ScheduleRowView(jadwal: jadwal) {
                                scheduleToEdit = jadwal
                                showEditSchedule = true
                            } onDelete: {
                                scheduleToDelete = jadwal
                                showDeleteAlert = true
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60)).foregroundColor(.secondary.opacity(0.5))
            Text(isEN ? "No Schedules Yet" : "Belum Ada Jadwal")
                .font(.title3).fontWeight(.semibold).foregroundColor(.secondary)
            Text(isEN
                ? "Add a schedule using the buttons above"
                : "Tambahkan jadwal menggunakan tombol di atas")
                .font(.subheadline).foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private let dayOrder = ["Senin","Selasa","Rabu","Kamis","Jumat","Sabtu","Minggu"]

    private var groupedSchedules: [String: [JadwalKuliah]] {
        Dictionary(grouping: scheduleManager.jadwalList) { extractDay(from: $0.jadwal) }
    }

    private func extractDay(from schedule: String) -> String {
        dayOrder.first { schedule.contains($0) } ?? (isEN ? "Other" : "Lainnya")
    }

    private func localizedDay(_ day: String) -> String {
        if !isEN { return day }
        let map = ["Senin":"Monday","Selasa":"Tuesday","Rabu":"Wednesday",
                   "Kamis":"Thursday","Jumat":"Friday","Sabtu":"Saturday","Minggu":"Sunday"]
        return map[day] ?? day
    }

    private func deleteSchedule(_ jadwal: JadwalKuliah) {
        scheduleManager.jadwalList.removeAll { $0.id == jadwal.id }
    }
}

// MARK: - Schedule Row View
struct ScheduleRowView: View {
    let jadwal: JadwalKuliah
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(jadwal.color)
                .frame(width: 4, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(jadwal.namaMataKuliah)
                    .font(.subheadline).fontWeight(.semibold).lineLimit(2)
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill").font(.caption2)
                    Text(extractTime(from: jadwal.jadwal)).font(.caption)
                }
                .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill").font(.caption2)
                    Text(jadwal.dosen).font(.caption).lineLimit(1)
                }
                .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil").font(.callout).foregroundColor(.blue)
                        .padding(8).background(Color.blue.opacity(0.1)).clipShape(Circle())
                }
                Button(action: onDelete) {
                    Image(systemName: "trash.fill").font(.callout).foregroundColor(.red)
                        .padding(8).background(Color.red.opacity(0.1)).clipShape(Circle())
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.7))
        .cornerRadius(12)
    }

    private func extractTime(from schedule: String) -> String {
        if let r = schedule.range(of: "\\d{1,2}:\\d{2}\\s*-\\s*\\d{1,2}:\\d{2}", options: .regularExpression) {
            return String(schedule[r])
        }
        return schedule
    }
}
