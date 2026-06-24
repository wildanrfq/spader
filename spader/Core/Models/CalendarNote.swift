//
//  CalendarNote.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import Foundation
import SwiftUI

struct CalendarNote: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var note: String
    var colorHex: String
    
    init(id: UUID = UUID(), date: Date, note: String, colorHex: String? = nil) {
        self.id = id
        self.date = date
        self.note = note
        self.colorHex = colorHex ?? Color.blue.toHex()
    }
    
    var color: Color {
        return Color(hex: colorHex)
    }
}