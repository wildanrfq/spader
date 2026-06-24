//
//  JadwalKuliah.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import Foundation
import SwiftUI

struct JadwalKuliah: Identifiable, Codable, Equatable {
    let id: UUID
    let namaMataKuliah: String
    let jadwal: String
    let dosen: String
    var note: String?
    var colorHex: String?
    
    init(
        id: UUID = UUID(),
        namaMataKuliah: String,
        jadwal: String,
        dosen: String,
        note: String? = nil,
        colorHex: String? = nil
    ) {
        self.id = id
        self.namaMataKuliah = namaMataKuliah
        self.jadwal = jadwal
        self.dosen = dosen
        self.note = note
        self.colorHex = colorHex ?? Color.availableColors.randomElement()?.toHex()
    }
    
    var color: Color {
        if let hex = colorHex {
            return Color(hex: hex)
        }
        return .blue
    }
}
