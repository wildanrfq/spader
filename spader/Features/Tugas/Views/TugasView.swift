//
//  TugasView.swift
//  spader
//

import SwiftUI

struct TugasView: View {
    @EnvironmentObject var tugasManager: TugasManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var scheduleManager: ScheduleManager
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedFilter: TugasFilter = .aktif
    @State private var showAddTugas = false
    @State private var selectedTugas: Tugas?
    @State private var tugasToDelete: Tugas?
    @State private var showDeleteOne = false
    @State private var showDeleteAllSelesai = false

    // Completion animation
    @State private var showCompleteAnim = false
    @State private var completedTugasName = ""

    enum TugasFilter: String, CaseIterable {
        case aktif = "Aktif"
        case selesai = "Selesai"
    }

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(languageManager.strings.tugasTitle)
                            .font(.title2.bold()).foregroundColor(.primary)
                        if tugasManager.aktifCount > 0 {
                            let isEN = languageManager.strings.navHome == "Home"
                            Text("\(tugasManager.aktifCount) \(isEN ? "active tasks" : "tugas aktif")\(tugasManager.overdueCount > 0 ? " • \(tugasManager.overdueCount) \(isEN ? "overdue" : "terlambat")" : "")")
                                .font(.caption)
                                .foregroundColor(tugasManager.overdueCount > 0 ? .red : .secondary)
                        }
                    }
                    Spacer()

                    // "Hapus Semua Selesai" — only in selesai tab
                    if selectedFilter == .selesai && !tugasManager.selesai.isEmpty {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showDeleteAllSelesai = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                                .frame(width: 36, height: 36)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }

                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showAddTugas = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28)).foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)

                // MARK: Filter Tabs
                HStack(spacing: 0) {
                    ForEach(TugasFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) { selectedFilter = filter }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Text(filter == .aktif ? languageManager.strings.tugasActive : languageManager.strings.tugasCompleted)
                                        .font(.system(size: 15, weight: selectedFilter == filter ? .semibold : .regular))
                                        .lineLimit(1)
                                    if filter == .aktif && tugasManager.overdueCount > 0 {
                                        badgePill("\(tugasManager.overdueCount)", color: .red)
                                    } else if filter == .aktif && tugasManager.aktifCount > 0 {
                                        badgePill("\(tugasManager.aktifCount)", color: .blue)
                                    } else if filter == .selesai && !tugasManager.selesai.isEmpty {
                                        badgePill("\(tugasManager.selesai.count)", color: .green)
                                    }
                                }
                                .foregroundColor(selectedFilter == filter ? .blue : .secondary)

                                Rectangle()
                                    .fill(selectedFilter == filter ? Color.blue : Color.clear)
                                    .frame(height: 2.5).cornerRadius(1.5)
                            }
                            .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                .background(colorScheme == .dark ? Color(white: 0.2).opacity(0.5) : Color.white.opacity(0.6))

                Divider().background(Color.gray.opacity(0.3))

                // MARK: Content
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if selectedFilter == .aktif {
                            if tugasManager.aktif.isEmpty {
                                EmptyTugasView(filter: .aktif, onAdd: { showAddTugas = true })
                            } else {
                                ForEach(tugasManager.aktif) { tugas in
                                    TugasCard(
                                        tugas: tugas,
                                        onToggle: {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            tugasManager.toggleSelesai(tugas)
                                            // Trigger completion animation
                                            if !tugas.isSelesai {
                                                completedTugasName = tugas.judul
                                                withAnimation { showCompleteAnim = true }
                                            }
                                        },
                                        onTap: { selectedTugas = tugas },
                                        onDelete: {
                                            tugasToDelete = tugas
                                            showDeleteOne = true
                                        }
                                    )
                                }
                            }
                        } else {
                            if tugasManager.selesai.isEmpty {
                                EmptyTugasView(filter: .selesai, onAdd: { showAddTugas = true })
                            } else {
                                ForEach(tugasManager.selesai) { tugas in
                                    TugasCard(
                                        tugas: tugas,
                                        onToggle: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            tugasManager.toggleSelesai(tugas)
                                        },
                                        onTap: { selectedTugas = tugas },
                                        onDelete: {
                                            tugasToDelete = tugas
                                            showDeleteOne = true
                                        }
                                    )
                                }
                            }
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 12)
                }
            }

            // MARK: Completion Animation Overlay
            if showCompleteAnim {
                CompletionAnimationView(
                    doneTitle: languageManager.strings.tugasDoneTitle,
                    tugasName: completedTugasName,
                    onFinish: { withAnimation { showCompleteAnim = false } }
                )
                .transition(.opacity)
                .zIndex(99)
            }
        }
        .sheet(isPresented: $showAddTugas) {
            AddEditTugasView(mode: .add)
                .environmentObject(tugasManager)
                .environmentObject(scheduleManager)
        }
        .sheet(item: $selectedTugas) { tugas in
            AddEditTugasView(mode: .edit(tugas))
                .environmentObject(tugasManager)
                .environmentObject(scheduleManager)
        }
        // Hapus satu tugas
        .confirmationDialog(languageManager.strings.tugasDeleteTitle, isPresented: $showDeleteOne, titleVisibility: .visible) {
            Button(languageManager.strings.actionDelete, role: .destructive) {
                if let t = tugasToDelete {
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    withAnimation { tugasManager.hapus(t) }
                }
            }
            Button(languageManager.strings.actionCancel, role: .cancel) {}
        }
        // Hapus semua selesai
        .confirmationDialog(
            languageManager.strings.tugasDeleteAllTitle,
            isPresented: $showDeleteAllSelesai,
            titleVisibility: .visible
        ) {
            Button("Hapus Semua (\(tugasManager.selesai.count))", role: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                withAnimation {
                    tugasManager.selesai.forEach { tugasManager.hapus($0) }
                }
            }
            Button(languageManager.strings.actionCancel, role: .cancel) {}
        }
    }

    @ViewBuilder
    private func badgePill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 5).padding(.vertical, 2)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Completion Animation
struct CompletionAnimationView: View {
    let doneTitle: String
    let tugasName: String
    let onFinish: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var checkScale: CGFloat = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.8

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onFinish() }

            VStack(spacing: 20) {
                // Animated checkmark
                ZStack {
                    // Expanding ring
                    Circle()
                        .stroke(Color.green.opacity(ringOpacity), lineWidth: 3)
                        .frame(width: 100, height: 100)
                        .scaleEffect(ringScale)

                    // Solid circle background
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                        .scaleEffect(scale)

                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(checkScale)
                }

                VStack(spacing: 6) {
                    Text(doneTitle)
                        .font(.headline).foregroundColor(.white)
                    Text(tugasName)
                        .font(.subheadline).foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            // Spring in: circle
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
            }
            // Checkmark slight delay
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.15)) {
                checkScale = 1.0
            }
            // Ring expand + fade
            withAnimation(.easeOut(duration: 0.7).delay(0.1)) {
                ringScale = 1.8
                ringOpacity = 0
            }
            // Text fade in
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                opacity = 1
            }
            // Auto dismiss after 1.6s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 0.5
                    checkScale = 0
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onFinish()
                }
            }
        }
    }
}

// MARK: - Empty State
struct EmptyTugasView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let filter: TugasView.TugasFilter
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: filter == .aktif ? "checkmark.circle" : "tray")
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.35))
            Text(filter == .aktif ? languageManager.strings.tugasNoActive : languageManager.strings.tugasNoCompleted)
                .font(.subheadline).foregroundColor(.secondary)
            if filter == .aktif {
                Button(action: onAdd) {
                    Label(languageManager.strings.tugasAdd, systemImage: "plus")
                        .font(.subheadline.weight(.semibold)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color.blue).cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity).padding(.top, 60)
    }
}
