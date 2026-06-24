//
//  DayCell.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let note: CalendarNote?
    let hasSchedule: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
            
            HStack(spacing: 2) {
                if hasSchedule {
                    Circle()
                        .fill(isSelected ? Color.white : Color.blue)
                        .frame(width: 4, height: 4)
                }
                
                if note != nil {
                    Circle()
                        .fill(isSelected ? Color.white : note!.color)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : (colorScheme == .dark ? Color(white: 0.2) : Color.white)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
