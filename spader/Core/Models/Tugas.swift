//
//  Tugas.swift
//  spader
//
//  Core/Models/Tugas.swift
//

import Foundation
import SwiftUI

enum TugasStatus: String, Codable, CaseIterable {
    case aktif = "aktif"
    case selesai = "selesai"
    case terlambat = "terlambat"

    var label: String { localizedLabel(isEN: false) }

    func localizedLabel(isEN: Bool) -> String {
        switch self {
        case .aktif:     return isEN ? "Active"   : "Aktif"
        case .selesai:   return isEN ? "Done"     : "Selesai"
        case .terlambat: return isEN ? "Overdue"  : "Terlambat"
        }
    }

    var color: Color {
        switch self {
        case .aktif: return .blue
        case .selesai: return .green
        case .terlambat: return .red
        }
    }

    var icon: String {
        switch self {
        case .aktif: return "clock.fill"
        case .selesai: return "checkmark.circle.fill"
        case .terlambat: return "exclamationmark.circle.fill"
        }
    }
}

enum TugasPrioritas: String, Codable, CaseIterable {
    case rendah = "rendah"
    case sedang = "sedang"
    case tinggi = "tinggi"

    var label: String { localizedLabel(isEN: false) }

    func localizedLabel(isEN: Bool) -> String {
        switch self {
        case .rendah: return isEN ? "Low"    : "Rendah"
        case .sedang: return isEN ? "Medium" : "Sedang"
        case .tinggi: return isEN ? "High"   : "Tinggi"
        }
    }

    var color: Color {
        switch self {
        case .rendah: return .green
        case .sedang: return .orange
        case .tinggi: return .red
        }
    }

    var icon: String {
        switch self {
        case .rendah: return "arrow.down.circle.fill"
        case .sedang: return "minus.circle.fill"
        case .tinggi: return "arrow.up.circle.fill"
        }
    }
}

struct Tugas: Identifiable, Codable, Equatable {
    let id: UUID
    var judul: String
    var deskripsi: String
    var mataKuliah: String          // nama matkul
    var mataKuliahColorHex: String  // warna dari matkul
    var deadline: Date
    var prioritas: TugasPrioritas
    var isSelesai: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        judul: String,
        deskripsi: String = "",
        mataKuliah: String,
        mataKuliahColorHex: String = "007AFF",
        deadline: Date,
        prioritas: TugasPrioritas = .sedang,
        isSelesai: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.judul = judul
        self.deskripsi = deskripsi
        self.mataKuliah = mataKuliah
        self.mataKuliahColorHex = mataKuliahColorHex
        self.deadline = deadline
        self.prioritas = prioritas
        self.isSelesai = isSelesai
        self.createdAt = createdAt
    }

    var mataKuliahColor: Color {
        Color(hex: mataKuliahColorHex)
    }

    var status: TugasStatus {
        if isSelesai { return .selesai }
        if deadline < Date() { return .terlambat }
        return .aktif
    }

    var hariSisaText: String { localizedHariSisa(isEN: false) }

    func localizedHariSisa(isEN: Bool) -> String {
        if isSelesai { return isEN ? "Done" : "Selesai" }
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: deadline)
        let days = diff.day ?? 0
        let hours = diff.hour ?? 0
        let minutes = diff.minute ?? 0

        if days < 0 || (days == 0 && hours < 0) {
            return isEN ? "Overdue" : "Terlambat"
        } else if days == 0 && hours == 0 {
            return isEN ? "\(max(0, minutes)) min left" : "\(max(0, minutes)) menit lagi"
        } else if days == 0 {
            return isEN ? "\(hours) hr left" : "\(hours) jam lagi"
        } else if days == 1 {
            return isEN ? "Tomorrow" : "Besok"
        } else {
            return isEN ? "\(days) days left" : "\(days) hari lagi"
        }
    }

    var isDeadlineSoon: Bool {
        guard !isSelesai else { return false }
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: deadline).hour ?? 0
        return hours <= 24 && deadline > Date()
    }

    var isOverdue: Bool {
        !isSelesai && deadline < Date()
    }
}
