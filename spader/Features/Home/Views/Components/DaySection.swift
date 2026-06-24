//
//  DaySection.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct DaySection: View {
    let day: String
    let schedules: [JadwalKuliah]
    @Binding var expandedDays: Set<String>
    let onScheduleTap: (JadwalKuliah) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if expandedDays.contains(day) {
                        expandedDays.remove(day)
                    } else {
                        expandedDays.insert(day)
                    }
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack {
                    Text(day)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("(\(schedules.count))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: expandedDays.contains(day) ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption.bold())
                }
                .padding()
                .background(colorScheme == .dark ? Color(white: 0.2) : Color.white.opacity(0.7))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            if expandedDays.contains(day) {
                ForEach(schedules) { jadwal in
                    ScheduleCard(jadwal: jadwal) {
                        onScheduleTap(jadwal)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}