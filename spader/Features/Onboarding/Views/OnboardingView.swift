//
//  OnboardingView.swift
//  spader
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("name") private var userName = ""
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage = 0
    @State private var inputName = ""
    @State private var showError = false

    var body: some View {
        let s = languageManager.strings
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                if currentPage > 0 {
                    HStack(spacing: 6) {
                        ForEach(1..<4) { i in
                            Capsule()
                                .fill(currentPage == i ? Color.blue : Color.gray.opacity(0.4))
                                .frame(width: currentPage == i ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                }

                TabView(selection: $currentPage) {
                    NamePage(
                        inputName: $inputName,
                        showError: $showError,
                        welcomeText: s.onboardingWelcome,
                        nameLabel: s.onboardingNameLabel,
                        nameHint: s.onboardingNameHint,
                        nameError: s.onboardingNameError,
                        continueLabel: s.onboardingNext,
                        onContinue: { saveName() }
                    )
                    .tag(0)

                    TutorialPage(
                        icon: "doc.text.fill",
                        iconColor: .blue,
                        title: s.onboardingPage1Title,
                        description: s.onboardingPage1Desc,
                        tip: s.onboardingPage1Tip,
                        exampleView: AnyView(ImportExample()),
                        nextLabel: s.onboardingNext,
                        onNext: { withAnimation { currentPage = 2 } }
                    )
                    .tag(1)

                    TutorialPage(
                        icon: "bell.badge.fill",
                        iconColor: .orange,
                        title: s.onboardingPage2Title,
                        description: s.onboardingPage2Desc,
                        tip: s.onboardingPage2Tip,
                        exampleView: AnyView(NotifExample()),
                        nextLabel: s.onboardingNext,
                        onNext: { withAnimation { currentPage = 3 } }
                    )
                    .tag(2)

                    TutorialPage(
                        icon: "square.grid.2x2.fill",
                        iconColor: .purple,
                        title: s.onboardingPage3Title,
                        description: s.onboardingPage3Desc,
                        tip: s.onboardingPage3Tip,
                        exampleView: AnyView(WidgetExample()),
                        nextLabel: s.onboardingStart,
                        onNext: {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            hasCompletedOnboarding = true
                        },
                        isLast: true
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
            }
        }
    }

    private func saveName() {
        let trimmed = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            withAnimation { showError = true }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showError = false } }
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        userName = trimmed
        withAnimation { currentPage = 1 }
    }
}

// MARK: - Name Page
private struct NamePage: View {
    @Binding var inputName: String
    @Binding var showError: Bool
    let welcomeText: String
    let nameLabel: String
    let nameHint: String
    let nameError: String
    let continueLabel: String
    let onContinue: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    Image(.spader).resizable().scaledToFit().frame(height: 60)
                    Image(.upnvy).resizable().scaledToFit().frame(height: 60)
                }
                Text("Spader")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Spacer()

            VStack(spacing: 12) {
                Text(welcomeText)
                    .font(.system(size: 28, weight: .bold))
                Text(nameLabel)
                    .font(.system(size: 18))
                    .foregroundColor(.primary.opacity(0.8))
            }

            VStack(spacing: 14) {
                TextField("", text: $inputName,
                    prompt: Text(nameHint).foregroundColor(.primary.opacity(0.5)))
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.2) : Color.white.opacity(0.5))
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                        .stroke(showError ? Color.red : (colorScheme == .dark ? Color.gray.opacity(0.5) : Color.black.opacity(0.3)), lineWidth: 2))
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if showError {
                    Text(nameError)
                        .font(.caption).foregroundColor(.red).padding(.horizontal, 30)
                }
            }
            .padding(.top, 30)

            Button(action: onContinue) {
                Text("\(continueLabel) →")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.top, 16)

            Spacer()
        }
    }
}

// MARK: - Tutorial Page
private struct TutorialPage: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let tip: String
    let exampleView: AnyView
    let nextLabel: String
    let onNext: () -> Void
    var isLast: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: icon)
                    .font(.system(size: 38))
                    .foregroundColor(iconColor)
            }
            .padding(.bottom, 20)

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            exampleView
                .padding(.top, 20)
                .padding(.horizontal, 24)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                    .padding(.top, 1)
                Text(tip)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(colorScheme == .dark ? Color(white: 0.18) : Color.yellow.opacity(0.08))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 28)
            .padding(.top, 16)

            Spacer()

            Button(action: onNext) {
                Text(isLast ? "\(nextLabel) 🚀" : "\(nextLabel) →")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(iconColor)
                    .cornerRadius(15)
                    .shadow(color: iconColor.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Example Views
private struct ImportExample: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Contoh format teks:")
                .font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("IF21\t123210001\tBasis Data\tIF-A\t3")
                Text("Senin 10:00 - 12:00 Patt.I-3A")
                Text("Dr. Budi Santoso M.T.")
                Text("0")
            }
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(.primary.opacity(0.8))
            .padding(10)
            .background(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.96))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.2), lineWidth: 1))
        }
    }
}

private struct NotifExample: View {
    var body: some View {
        HStack(spacing: 10) {
            ForEach(["15 mnt", "30 mnt", "1 jam"], id: \.self) { t in
                Text(t)
                    .font(.caption).fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.orange.opacity(0.85))
                    .cornerRadius(20)
            }
        }
    }
}

private struct WidgetExample: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar").font(.system(size: 9)).foregroundColor(.white)
                    Text("Hari Ini").font(.system(size: 9, weight: .semibold)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Basis Data (IF-A)")
                        .font(.system(size: 8, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill").font(.system(size: 6)).foregroundColor(.white.opacity(0.8))
                        Text("10:00 - 12:00").font(.system(size: 7)).foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(5)
                .background(Color.white.opacity(0.2))
                .cornerRadius(4)
            }
            .padding(8)
            .frame(width: 110, height: 70)
            .background(Color.blue)
            .cornerRadius(14)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 3) {
                    Text("10:00").font(.system(size: 9, weight: .semibold)).foregroundColor(.white).frame(width: 32, alignment: .leading)
                    Text("Basis Data").font(.system(size: 9)).foregroundColor(.white.opacity(0.9)).lineLimit(1)
                }
                HStack(spacing: 3) {
                    Text("12:30").font(.system(size: 9, weight: .semibold)).foregroundColor(.white).frame(width: 32, alignment: .leading)
                    Text("Rekayasa PL").font(.system(size: 9)).foregroundColor(.white.opacity(0.9)).lineLimit(1)
                }
            }
            .padding(8)
            .frame(width: 140, height: 50)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}
