//
//  BottomButtons.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct BottomButtons: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var showResetAlert: Bool
    @Binding var showAbout: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label(languageManager.strings.settingsReset, systemImage: "arrow.clockwise.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
            }
            .foregroundColor(.orange)
            
            Button {
                showAbout = true
            } label: {
                Label(languageManager.strings.settingsAbout, systemImage: "info.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
            }
            .foregroundColor(.green)
        }
    }
}