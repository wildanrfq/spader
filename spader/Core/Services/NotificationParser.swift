//
//  NotificationParser.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import Foundation

class NotificationParser {
    static func extractScheduleInfo(from jadwalString: String) -> (day: Int, hour: Int, minute: Int)? {
        let dayMapping = [
            "Minggu": 1, "Senin": 2, "Selasa": 3, "Rabu": 4,
            "Kamis": 5, "Jumat": 6, "Sabtu": 7
        ]
        
        var dayNumber = 0
        for (dayName, dayNum) in dayMapping {
            if jadwalString.contains(dayName) {
                dayNumber = dayNum
                break
            }
        }
        
        guard dayNumber > 0 else { return nil }
        
        let timePattern = "(\\d{1,2}):(\\d{2})"
        guard let regex = try? NSRegularExpression(pattern: timePattern),
              let match = regex.firstMatch(in: jadwalString, range: NSRange(jadwalString.startIndex..., in: jadwalString)),
              let hourRange = Range(match.range(at: 1), in: jadwalString),
              let minuteRange = Range(match.range(at: 2), in: jadwalString),
              let hour = Int(jadwalString[hourRange]),
              let minute = Int(jadwalString[minuteRange]) else {
            return nil
        }
        
        return (dayNumber, hour, minute)
    }
}