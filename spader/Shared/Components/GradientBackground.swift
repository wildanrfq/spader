//
//  GradientBackground.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark ? [
                Color(white: 0.1),
                Color(white: 0.15)
            ] : [
                Color(white: 0.98),
                Color(white: 0.92)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}