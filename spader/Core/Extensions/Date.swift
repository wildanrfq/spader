//
//  Date.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func isInSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func dayName() -> String {
        let weekday = Calendar.current.component(.weekday, from: self)
        let dayMapping = [1: "Minggu", 2: "Senin", 3: "Selasa", 4: "Rabu",
                          5: "Kamis", 6: "Jumat", 7: "Sabtu"]
        return dayMapping[weekday] ?? ""
    }
}
