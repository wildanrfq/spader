//
//  SemesterGPA.swift
//  spader
//
//  Core/Models/SemesterGPA.swift
//

import Foundation

struct SemesterGPA: Identifiable, Codable {
    let id: UUID
    let semester: Int
    let gpa: Double
    
    init(id: UUID = UUID(), semester: Int, gpa: Double) {
        self.id = id
        self.semester = semester
        self.gpa = gpa
    }
}
