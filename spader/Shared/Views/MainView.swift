import SwiftUI

struct MainView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var tugasManager = TugasManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0

    var body: some View {
        let s = languageManager.strings
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Image(.spader)
                        .resizable().scaledToFit().frame(height: 45)
                    Image(.upnvy)
                        .resizable().scaledToFit().frame(height: 45)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spader")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? Color(white: 0.2).opacity(0.5) : Color.white.opacity(0.5))

                Divider().background(Color.gray.opacity(0.3))

                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                        .tabItem { Label(s.navHome, systemImage: "house.fill") }

                    TugasView()
                        .tag(1)
                        .tabItem { Label(s.navTugas, systemImage: "checklist") }
                        .badge(badgeCount)

                    CalendarView()
                        .tag(2)
                        .tabItem { Label(s.navCalendar, systemImage: "calendar") }

                    SettingsView()
                        .tag(3)
                        .tabItem { Label(s.navSettings, systemImage: "gearshape.fill") }
                }
                .onAppear { applyTabBarAppearance() }
                .onChange(of: colorScheme) { _ in applyTabBarAppearance() }
            }
        }
        .tint(.blue)
        .environmentObject(tugasManager)
    }

    private var badgeCount: Int {
        let total = tugasManager.overdueCount + tugasManager.deadlineSoon.count
        return total > 0 ? total : 0
    }

    private func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        if colorScheme == .dark {
            appearance.backgroundColor = UIColor(white: 0.12, alpha: 0.95)
        } else {
            appearance.backgroundColor = UIColor(white: 1.0, alpha: 0.92)
        }

        let normal = UITabBarItemAppearance()
        normal.normal.iconColor = UIColor.secondaryLabel
        normal.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        normal.selected.iconColor = UIColor.systemBlue
        normal.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance = normal
        appearance.inlineLayoutAppearance = normal
        appearance.compactInlineLayoutAppearance = normal

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
