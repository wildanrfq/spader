//
//  NoteRow.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct NoteRow: View {
    let note: CalendarNote
    @Environment(\.colorScheme) var colorScheme
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(note.color)
                .frame(width: 6, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(note.note)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: note.date)
    }
}