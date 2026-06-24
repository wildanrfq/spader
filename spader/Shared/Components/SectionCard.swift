//
//  SectionCard.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct SectionCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    var alignment: HorizontalAlignment = .leading
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: alignment, spacing: 12) {
            content
        }
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}