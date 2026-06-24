//
//  HomeView.swift
//  spader
//

import SwiftUI
internal import Combine

struct HomeView: View {
    @AppStorage("name") private var name = ""
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showTodayOnly = false
    @State private var expandedDays: Set<String> = []
    @State private var selectedJadwal: JadwalKuliah?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var now = Date()

    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    // Day names in Indonesian (for schedule matching — schedules are always stored in ID)
    private let daysOfWeekID = ["Senin","Selasa","Rabu","Kamis","Jumat","Sabtu","Minggu"]

    var body: some View {
        let s = languageManager.strings
        let daysOfWeek = [s.dayMonday, s.dayTuesday, s.dayWednesday, s.dayThursday,
                          s.dayFriday, s.daySaturday, s.daySunday]

        ZStack {
            GradientBackground()

            VStack(alignment: .leading, spacing: 0) {
                // MARK: Header
                HStack {
                    if isSearching {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField(s.homeSearchPlaceholder, text: $searchText)
                                .font(.subheadline)
                                .autocorrectionDisabled()
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.93))
                        .cornerRadius(12)

                        Button(s.actionCancel) {
                            withAnimation(.spring(response: 0.3)) {
                                isSearching = false
                                searchText = ""
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(getGreeting(s))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(name)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) { isSearching = true }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(colorScheme == .dark ? Color(white: 0.25) : Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }

                            Button(action: {
                                withAnimation { showTodayOnly.toggle() }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: showTodayOnly ? "calendar.circle.fill" : "calendar.circle")
                                    Text(showTodayOnly ? s.homeTodayFilter : s.homeAllFilter)
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(showTodayOnly ? Color.blue : Color.gray)
                                .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .animation(.spring(response: 0.3), value: isSearching)

                Divider().background(Color.gray.opacity(0.3))

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {

                        // MARK: Countdown Card
                        if !isSearching && !scheduleManager.jadwalList.isEmpty {
                            if let next = nextClass() {
                                CountdownCard(jadwal: next, now: now)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                            }
                        }

                        // MARK: Section Title
                        Group {
                            if isSearching {
                                Text(searchText.isEmpty ? s.homeAllSchedules : s.homeSearchResults)
                                    .font(.title2.bold())
                            } else {
                                Text(showTodayOnly ? s.homeTodaySchedule : s.homeLectureSchedule)
                                    .font(.title2.bold())
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                        // MARK: Content
                        if scheduleManager.jadwalList.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary.opacity(0.4))
                                Text(s.homeNoSchedule)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)

                        } else if isSearching {
                            let results = searchResults()
                            if results.isEmpty && !searchText.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 36))
                                        .foregroundColor(.secondary.opacity(0.4))
                                    Text("\(s.homeNoResults): \"\(searchText)\"")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                ForEach(results) { jadwal in
                                    ScheduleCard(jadwal: jadwal) {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        selectedJadwal = jadwal
                                    }
                                }
                            }

                        } else if showTodayOnly {
                            let todaySchedule = getTodaySchedule()
                            if todaySchedule.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "sun.max")
                                        .font(.system(size: 36))
                                        .foregroundColor(.secondary.opacity(0.4))
                                    Text(s.homeNoTodaySchedule)
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                ForEach(todaySchedule) { jadwal in
                                    ScheduleCard(jadwal: jadwal) {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        selectedJadwal = jadwal
                                    }
                                }
                            }

                        } else {
                            ForEach(Array(daysOfWeekID.enumerated()), id: \.offset) { index, dayID in
                                let dayLabel = daysOfWeek[index]
                                let daySchedules = getSchedulesForDay(dayID)
                                if !daySchedules.isEmpty {
                                    DaySection(
                                        day: dayLabel,
                                        schedules: daySchedules,
                                        expandedDays: $expandedDays
                                    ) { jadwal in
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        selectedJadwal = jadwal
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 80)
                    }
                }
            }

            // Floating Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        openSpadaInSafari()
                    }) {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $selectedJadwal) { jadwal in
            CourseDetailView(jadwal: jadwal)
                .environmentObject(scheduleManager)
        }
        .onReceive(timer) { t in now = t }
    }

    // MARK: - Countdown Logic
    private func nextClass() -> JadwalKuliah? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let dayMapping = [1:"Minggu",2:"Senin",3:"Selasa",4:"Rabu",5:"Kamis",6:"Jumat",7:"Sabtu"]
        let today = dayMapping[weekday] ?? "Senin"
        let currentMin = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)

        return scheduleManager.jadwalList
            .filter { $0.jadwal.contains(today) }
            .compactMap { jadwal -> (JadwalKuliah, Int)? in
                guard let end = extractEndMinutes(from: jadwal.jadwal), end > currentMin,
                      let start = extractStartMinutes(from: jadwal.jadwal) else { return nil }
                return (jadwal, start)
            }
            .sorted { $0.1 < $1.1 }
            .first?.0
    }

    private func extractStartMinutes(from schedule: String) -> Int? {
        let p = "(\\d{1,2}):(\\d{2})\\s*-"
        guard let r = try? NSRegularExpression(pattern: p),
              let m = r.firstMatch(in: schedule, range: NSRange(schedule.startIndex..., in: schedule)),
              let h = Range(m.range(at: 1), in: schedule), let min = Range(m.range(at: 2), in: schedule),
              let hh = Int(schedule[h]), let mm = Int(schedule[min]) else { return nil }
        return hh * 60 + mm
    }

    private func extractEndMinutes(from schedule: String) -> Int? {
        let p = "-\\s*(\\d{1,2}):(\\d{2})"
        guard let r = try? NSRegularExpression(pattern: p),
              let m = r.firstMatch(in: schedule, range: NSRange(schedule.startIndex..., in: schedule)),
              let h = Range(m.range(at: 1), in: schedule), let min = Range(m.range(at: 2), in: schedule),
              let hh = Int(schedule[h]), let mm = Int(schedule[min]) else { return nil }
        return hh * 60 + mm
    }

    // MARK: - Search
    private func searchResults() -> [JadwalKuliah] {
        guard !searchText.isEmpty else { return scheduleManager.jadwalList }
        let q = searchText.lowercased()
        return scheduleManager.jadwalList.filter {
            $0.namaMataKuliah.lowercased().contains(q) ||
            $0.dosen.lowercased().contains(q) ||
            $0.jadwal.lowercased().contains(q)
        }
    }

    // MARK: - Helpers
    private func getGreeting(_ s: AppStrings) -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<11: return s.greetingMorning
        case 11..<15: return s.greetingAfternoon
        case 15..<18: return s.greetingEvening
        default: return s.greetingNight
        }
    }

    private func getTodaySchedule() -> [JadwalKuliah] {
        scheduleManager.jadwalList.filter { $0.jadwal.contains(getCurrentDay()) }
    }

    private func getSchedulesForDay(_ day: String) -> [JadwalKuliah] {
        scheduleManager.jadwalList.filter { $0.jadwal.contains(day) }
    }

    private func getCurrentDay() -> String {
        let w = Calendar.current.component(.weekday, from: Date())
        return [1:"Minggu",2:"Senin",3:"Selasa",4:"Rabu",5:"Kamis",6:"Jumat",7:"Sabtu"][w] ?? "Senin"
    }

    private func openSpadaInSafari() {
        if let url = URL(string: "https://spada.upnyk.ac.id/login/index.php") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Countdown Card
struct CountdownCard: View {
    @EnvironmentObject var languageManager: LanguageManager
    let jadwal: JadwalKuliah
    let now: Date
    @Environment(\.colorScheme) var colorScheme

    private var currentMinutes: Int {
        let c = Calendar.current
        return c.component(.hour, from: now) * 60 + c.component(.minute, from: now)
    }

    private var startMinutes: Int? {
        let p = "(\\d{1,2}):(\\d{2})\\s*-"
        guard let r = try? NSRegularExpression(pattern: p),
              let m = r.firstMatch(in: jadwal.jadwal, range: NSRange(jadwal.jadwal.startIndex..., in: jadwal.jadwal)),
              let h = Range(m.range(at: 1), in: jadwal.jadwal),
              let min = Range(m.range(at: 2), in: jadwal.jadwal),
              let hh = Int(jadwal.jadwal[h]), let mm = Int(jadwal.jadwal[min]) else { return nil }
        return hh * 60 + mm
    }

    private var endMinutes: Int? {
        let p = "-\\s*(\\d{1,2}):(\\d{2})"
        guard let r = try? NSRegularExpression(pattern: p),
              let m = r.firstMatch(in: jadwal.jadwal, range: NSRange(jadwal.jadwal.startIndex..., in: jadwal.jadwal)),
              let h = Range(m.range(at: 1), in: jadwal.jadwal),
              let min = Range(m.range(at: 2), in: jadwal.jadwal),
              let hh = Int(jadwal.jadwal[h]), let mm = Int(jadwal.jadwal[min]) else { return nil }
        return hh * 60 + mm
    }

    private var isOngoing: Bool {
        guard let s = startMinutes, let e = endMinutes else { return false }
        return currentMinutes >= s && currentMinutes < e
    }

    private var minutesUntil: Int {
        guard let s = startMinutes else { return 0 }
        return max(0, s - currentMinutes)
    }

    private var statusColor: Color {
        if isOngoing { return .green }
        if minutesUntil <= 15 { return .red }
        if minutesUntil <= 30 { return .orange }
        return .blue
    }

    private var countdownText: String {
        let s = languageManager.strings
        if isOngoing { return s.homeOngoing }
        if minutesUntil == 0 { return s.homeStartsNow }
        if minutesUntil < 60 { return "\(minutesUntil) \(s.homeMinutesLeft)" }
        let h = minutesUntil / 60
        let m = minutesUntil % 60
        return m == 0 ? "\(h) \(s.homeHourLeft)" : "\(h) \(s.homeHourLeft) \(m) \(s.homeMinutesLeft)"
    }

    private var location: String {
        var str = jadwal.jadwal
        ["Senin","Selasa","Rabu","Kamis","Jumat","Sabtu","Minggu"].forEach {
            str = str.replacingOccurrences(of: $0, with: "")
        }
        if let r = try? NSRegularExpression(pattern: "\\d{1,2}:\\d{2}\\s*-\\s*\\d{1,2}:\\d{2}") {
            str = r.stringByReplacingMatches(in: str, range: NSRange(str.startIndex..., in: str), withTemplate: "")
        }
        str = str.replacingOccurrences(of: "-\\s*\\d{1,2}:\\d{2}", with: "", options: .regularExpression)
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
                  .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private var displayTime: String {
        if let r = jadwal.jadwal.range(of: "\\d{1,2}:\\d{2}\\s*-\\s*\\d{1,2}:\\d{2}", options: .regularExpression) {
            return String(jadwal.jadwal[r])
        }
        return ""
    }

    var body: some View {
        let s = languageManager.strings
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(statusColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(isOngoing ? s.homeOngoingLabel : s.homeNextClass)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                    Spacer()
                    if isOngoing {
                        Circle().fill(Color.green).frame(width: 7, height: 7)
                    }
                }

                Text(jadwal.namaMataKuliah)
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.primary).lineLimit(1)

                HStack(spacing: 12) {
                    if !displayTime.isEmpty {
                        Label(displayTime, systemImage: "clock.fill")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    if !location.isEmpty {
                        Label(location, systemImage: "mappin.circle.fill")
                            .font(.caption).foregroundColor(.secondary).lineLimit(1)
                    }
                }

                Text(countdownText)
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(statusColor.opacity(0.12))
                    .cornerRadius(6)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(white: 0.18) : Color.white)
        .cornerRadius(14)
        .shadow(color: statusColor.opacity(0.15), radius: 8, x: 0, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(statusColor.opacity(0.2), lineWidth: 1))
    }
}
