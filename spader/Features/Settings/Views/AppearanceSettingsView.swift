//
//  AppearanceSettingsView.swift
//  spader
//

import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @State private var selectedAppearance: AppearanceMode = .system

    private var s: AppStrings { languageManager.strings }
    private var isEN: Bool { s.navHome == "Home" }

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()

                VStack(spacing: 20) {
                    Text(isEN ? "Choose the app display theme" : "Pilih tema tampilan aplikasi")
                        .font(.subheadline).foregroundColor(.secondary)
                        .padding(.top, 20)

                    VStack(spacing: 0) {
                        AppearanceButton(
                            icon: "sun.max.fill",
                            title: s.appearanceLight,
                            description: isEN ? "Light display" : "Tampilan terang",
                            isSelected: selectedAppearance == .light
                        ) { select(.light) }

                        Divider().padding(.leading, 60)

                        AppearanceButton(
                            icon: "moon.fill",
                            title: s.appearanceDark,
                            description: isEN ? "Dark display" : "Tampilan gelap",
                            isSelected: selectedAppearance == .dark
                        ) { select(.dark) }

                        Divider().padding(.leading, 60)

                        AppearanceButton(
                            icon: "circle.lefthalf.filled",
                            title: s.appearanceSystem,
                            description: isEN ? "Follow system settings" : "Mengikuti pengaturan sistem",
                            isSelected: selectedAppearance == .system
                        ) { select(.system) }
                    }
                    .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle(s.appearanceTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEN ? "Done" : "Selesai") { dismiss() }
                }
            }
        }
        .preferredColorScheme(selectedAppearance.colorScheme)
        .onAppear { selectedAppearance = appearance }
    }

    private func select(_ mode: AppearanceMode) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.35)) {
            selectedAppearance = mode
            appearance = mode
        }
    }
}

struct AppearanceButton: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium)).foregroundColor(.primary)
                    Text(description)
                        .font(.caption).foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue).font(.title3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding().contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
