//
//  ScheduleCard.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct ScheduleCard: View {
    let jadwal: JadwalKuliah
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 12) {
                // Color indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(jadwal.color)
                    .frame(width: 6)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(jadwal.namaMataKuliah)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(jadwal.jadwal)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person")
                            .font(.caption)
                        Text(jadwal.dosen)
                            .font(.footnote)
                    }
                    .foregroundColor(.secondary)
                    
                    if let note = jadwal.note, !note.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.caption)
                            Text(note)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    if colorScheme == .dark {
                        // Dark mode: left edge glow from card color
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(white: 0.15))
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(jadwal.color.opacity(0.3), lineWidth: 1)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: jadwal.color.opacity(0.08), radius: 6, x: 0, y: 2)
                    }
                }
            )
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}