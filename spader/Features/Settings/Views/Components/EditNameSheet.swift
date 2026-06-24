//
//  EditNameSheet.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct EditNameSheet: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var tempName: String
    @Binding var userName: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 20) {
                    Text(languageManager.strings.editNameTitle)
                        .font(.title2.bold())
                        .padding(.top, 20)
                    
                    TextField(languageManager.strings.editNameLabel, text: $tempName)
                        .font(.system(size: 18))
                        .padding()
                        .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(languageManager.strings.actionCancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(languageManager.strings.actionSave) {
                        let trimmed = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty { userName = trimmed }
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempName = userName
            }
        }
    }
}