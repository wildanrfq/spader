//
//  AppearanceMode.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

enum AppearanceMode: String, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}