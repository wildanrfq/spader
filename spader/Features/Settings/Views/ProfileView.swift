//
//  ProfileView.swift
//  spader
//

import SwiftUI
import Charts

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("name") private var userName = ""

    @State private var semesterGPAs: [SemesterGPA] = []
    @State private var showAddGPA = false
    @State private var showEditName = false
    @State private var tempName = ""

    private let gpaKey = "semesterGPAs"

    private var s: AppStrings { languageManager.strings }
    private var isEN: Bool { s.navHome == "Home" }

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        if !semesterGPAs.isEmpty { gpaOverviewCard }
                        semesterListSection
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle(s.profileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(s.actionClose) { dismiss() }
                }
            }
            .sheet(isPresented: $showAddGPA) {
                AddGPAView { sem, gpa in addSemesterGPA(semester: sem, gpa: gpa) }
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showEditName) {
                EditNameSheet(tempName: $tempName, userName: $userName)
                    .environmentObject(languageManager)
            }
            .onAppear { loadGPAData() }
        }
    }

    // MARK: - Sub Views

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 100, height: 100)
                Text(getInitials(from: userName))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
            }
            VStack(spacing: 8) {
                Text(userName.isEmpty ? (isEN ? "Name Not Set" : "Nama Belum Diatur") : userName)
                    .font(.title2).fontWeight(.bold)
                Button(action: { showEditName = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text(s.editNameTitle)
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.top, 20)
    }

    private var gpaOverviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "Cumulative GPA" : "IPK Kumulatif")
                        .font(.subheadline).foregroundColor(.secondary)
                    Text(String(format: "%.2f", calculateCumulativeGPA()))
                        .font(.system(size: 36, weight: .bold)).foregroundColor(.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(isEN ? "Total Semesters" : "Total Semester")
                        .font(.caption).foregroundColor(.secondary)
                    Text("\(semesterGPAs.count)")
                        .font(.title3).fontWeight(.semibold)
                }
            }
            if semesterGPAs.count > 1 {
                gpaChart
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.7))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    private var gpaChart: some View {
        let axisLabel = isEN ? "GPA" : "IPS"
        return Chart {
            ForEach(semesterGPAs.sorted(by: { $0.semester < $1.semester })) { item in
                LineMark(
                    x: .value("Semester", "Sem \(item.semester)"),
                    y: .value(axisLabel, item.gpa)
                )
                .foregroundStyle(.blue)
                .symbol(Circle())

                PointMark(
                    x: .value("Semester", "Sem \(item.semester)"),
                    y: .value(axisLabel, item.gpa)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
        .chartYScale(domain: 0...4.0)
    }

    private var semesterListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isEN ? "GPA per Semester" : "Daftar IPS per Semester")
                    .font(.headline)
                Spacer()
                Button(action: { showAddGPA = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(s.actionAdd)
                    }
                    .font(.subheadline).foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)

            if semesterGPAs.isEmpty {
                emptyGPAState
            } else {
                VStack(spacing: 8) {
                    ForEach(semesterGPAs.sorted(by: { $0.semester > $1.semester })) { item in
                        SemesterGPARow(semesterGPA: item, isEN: isEN) {
                            deleteSemester(item)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    private var emptyGPAState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            Text(isEN ? "No GPA Data Yet" : "Belum Ada Data IPS")
                .font(.subheadline).foregroundColor(.secondary)
            Button(action: { showAddGPA = true }) {
                Text(isEN ? "Add First GPA" : "Tambah IPS Pertama")
                    .font(.subheadline).foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private func getInitials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.isEmpty { return "?" }
        if words.count == 1 { return String(words[0].prefix(1)).uppercased() }
        return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
    }

    private func calculateCumulativeGPA() -> Double {
        guard !semesterGPAs.isEmpty else { return 0.0 }
        return semesterGPAs.reduce(0.0) { $0 + $1.gpa } / Double(semesterGPAs.count)
    }

    private func loadGPAData() {
        if let data = UserDefaults.standard.data(forKey: gpaKey),
           let decoded = try? JSONDecoder().decode([SemesterGPA].self, from: data) {
            semesterGPAs = decoded
        }
    }

    private func saveGPAData() {
        if let encoded = try? JSONEncoder().encode(semesterGPAs) {
            UserDefaults.standard.set(encoded, forKey: gpaKey)
        }
    }

    private func addSemesterGPA(semester: Int, gpa: Double) {
        semesterGPAs.append(SemesterGPA(semester: semester, gpa: gpa))
        saveGPAData()
    }

    private func deleteSemester(_ item: SemesterGPA) {
        semesterGPAs.removeAll { $0.id == item.id }
        saveGPAData()
    }
}

// MARK: - Semester GPA Row
struct SemesterGPARow: View {
    let semesterGPA: SemesterGPA
    let isEN: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Semester \(semesterGPA.semester)")
                    .font(.subheadline).fontWeight(.semibold)
                Text(gradeLabel)
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 12) {
                Text(String(format: "%.2f", semesterGPA.gpa))
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(gpaColor)
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption).foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.7))
        .cornerRadius(12)
    }

    private var gradeLabel: String {
        switch semesterGPA.gpa {
        case 3.5...4.0: return isEN ? "With Distinction"    : "Dengan Pujian"
        case 3.0..<3.5: return isEN ? "Very Satisfactory"   : "Sangat Memuaskan"
        case 2.5..<3.0: return isEN ? "Satisfactory"        : "Memuaskan"
        case 2.0..<2.5: return isEN ? "Sufficient"          : "Cukup"
        default:        return isEN ? "Insufficient"        : "Kurang"
        }
    }

    private var gpaColor: Color {
        switch semesterGPA.gpa {
        case 3.5...4.0: return .green
        case 3.0..<3.5: return .blue
        case 2.5..<3.0: return .orange
        default:        return .red
        }
    }
}

// MARK: - Add GPA View
struct AddGPAView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss

    @State private var semester = ""
    @State private var gpa = ""

    let onSave: (Int, Double) -> Void

    private var s: AppStrings { languageManager.strings }
    private var isEN: Bool { s.navHome == "Home" }

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                Form {
                    Section(header: Text(isEN ? "Semester Data" : "Data Semester")) {
                        TextField(isEN ? "Semester (e.g. 1, 2, 3...)" : "Semester (contoh: 1, 2, 3...)", text: $semester)
                            .keyboardType(.numberPad)
                        TextField(isEN ? "GPA (e.g. 3.75)" : "IPS (contoh: 3.75)", text: $gpa)
                            .keyboardType(.decimalPad)
                    }
                    Section {
                        Button(action: saveGPA) {
                            HStack {
                                Spacer()
                                Text(s.actionSave).fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .disabled(!isValid)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(s.editGpaTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(s.actionCancel) { dismiss() }
                }
            }
        }
    }

    private var isValid: Bool {
        guard let sem = Int(semester), sem > 0,
              let val = Double(gpa.replacingOccurrences(of: ",", with: ".")),
              val >= 0.0 && val <= 4.0 else { return false }
        return true
    }

    private func saveGPA() {
        guard let sem = Int(semester),
              let val = Double(gpa.replacingOccurrences(of: ",", with: ".")) else { return }
        onSave(sem, val)
        dismiss()
    }
}
