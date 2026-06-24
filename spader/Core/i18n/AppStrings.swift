// Core/i18n/AppStrings.swift
import Foundation
import SwiftUI

struct AppStrings {
    // Navigation
    let navHome: String
    let navTugas: String
    let navCalendar: String
    let navSettings: String

    // Settings
    let settingsStudentSubtitle: String
    let settingsGpaChart: String
    let settingsNoGpaData: String
    let settingsAddGpa: String
    let settingsManageSchedule: String
    let settingsAppearance: String
    let settingsNotification: String
    let settingsNotificationSubtitle: String
    let settingsAbout: String
    let settingsReset: String
    let settingsResetTitle: String
    let settingsResetBody: String
    let settingsLanguage: String
    let settingsLanguageSubtitle: String

    // Language names
    let langIndonesia: String
    let langEnglish: String

    // Appearance
    let appearanceTitle: String
    let appearanceSystem: String
    let appearanceLight: String
    let appearanceDark: String

    // Common actions
    let actionSave: String
    let actionCancel: String
    let actionReset: String
    let actionDelete: String
    let actionDeleteAll: String
    let actionClose: String
    let actionImport: String
    let actionOK: String
    let actionAdd: String

    // GPA
    let editGpaTitle: String
    let editGpaSubtitle: String
    let editGpaSemesterLabel: String
    let editGpaPlaceholder: String
    let editGpaAddSemester: String
    let editGpaIpkLabel: String

    // Home
    let homeAllSchedules: String
    let homeSearchResults: String
    let homeTodaySchedule: String
    let homeLectureSchedule: String
    let homeNoSchedule: String
    let homeNoResults: String
    let homeNoTodaySchedule: String
    let homeSearchPlaceholder: String
    let homeTodayFilter: String
    let homeAllFilter: String
    let homeOpenSpada: String
    let homeClassCount: String
    let homeOngoing: String
    let homeNextClass: String
    let homeStartsNow: String
    let homeMinutesLeft: String
    let homeHourLeft: String
    let homeOngoingLabel: String

    // Greeting
    let greetingMorning: String
    let greetingAfternoon: String
    let greetingEvening: String
    let greetingNight: String

    // Tugas
    let tugasTitle: String
    let tugasActive: String
    let tugasCompleted: String
    let tugasNoActive: String
    let tugasNoCompleted: String
    let tugasAdd: String
    let tugasEdit: String
    let tugasDeleteTitle: String
    let tugasDeleteAllTitle: String
    let tugasDoneTitle: String
    let tugasTitle2: String
    let tugasDesc: String
    let tugasCourse: String
    let tugasPriority: String
    let tugasDeadline: String
    let tugasSelectCourse: String
    let tugasTypeCourse: String

    // Calendar
    let calendarNoteLabel: String
    let calendarNoteHint: String
    let calendarColorLabel: String

    // Onboarding
    let onboardingWelcome: String
    let onboardingNameHint: String
    let onboardingNameLabel: String
    let onboardingNameError: String
    let onboardingNext: String
    let onboardingStart: String
    let onboardingPage1Title: String
    let onboardingPage1Desc: String
    let onboardingPage1Tip: String
    let onboardingPage2Title: String
    let onboardingPage2Desc: String
    let onboardingPage2Tip: String
    let onboardingPage3Title: String
    let onboardingPage3Desc: String
    let onboardingPage3Tip: String

    // Days (full, for schedule matching)
    let dayMonday: String
    let dayTuesday: String
    let dayWednesday: String
    let dayThursday: String
    let dayFriday: String
    let daySaturday: String
    let daySunday: String

    // Days short (calendar headers)
    let dayShortSun: String
    let dayShortMon: String
    let dayShortTue: String
    let dayShortWed: String
    let dayShortThu: String
    let dayShortFri: String
    let dayShortSat: String

    // Months
    let months: [String]

    // About
    let aboutDeveloper: String
    let aboutEmail: String
    let aboutVersion: String
    let aboutPlatform: String
    let aboutMadeFor: String

    // Misc
    let courseDetailSchedule: String
    let courseDetailLecturer: String
    let importHint: String
    let importPlaceholder: String
    let importTitle: String
    let manageScheduleTitle: String
    let manageScheduleEmpty: String
    let editNameTitle: String
    let editNameLabel: String
    let profileTitle: String
    let notifTitle: String
}

let IndonesianStrings = AppStrings(
    navHome: "Beranda",
    navTugas: "Tugas",
    navCalendar: "Kalender",
    navSettings: "Pengaturan",

    settingsStudentSubtitle: "Mahasiswa UPN Veteran Yogyakarta",
    settingsGpaChart: "Grafik IPS",
    settingsNoGpaData: "Belum ada data IPS",
    settingsAddGpa: "+ Tambah IPS",
    settingsManageSchedule: "Kelola Jadwal",
    settingsAppearance: "Pengaturan Tampilan",
    settingsNotification: "Pengaturan Notifikasi",
    settingsNotificationSubtitle: "Atur reminder jadwal kuliah",
    settingsAbout: "Tentang Aplikasi",
    settingsReset: "Reset Aplikasi",
    settingsResetTitle: "Reset Aplikasi?",
    settingsResetBody: "Semua data akan dihapus dan aplikasi akan ditutup.",
    settingsLanguage: "Bahasa",
    settingsLanguageSubtitle: "Pilih bahasa tampilan",

    langIndonesia: "Indonesia",
    langEnglish: "English",

    appearanceTitle: "Pengaturan Tampilan",
    appearanceSystem: "Sistem",
    appearanceLight: "Terang",
    appearanceDark: "Gelap",

    actionSave: "Simpan",
    actionCancel: "Batal",
    actionReset: "Reset",
    actionDelete: "Hapus",
    actionDeleteAll: "Hapus Semua",
    actionClose: "Tutup",
    actionImport: "Import",
    actionOK: "OK",
    actionAdd: "Tambah",

    editGpaTitle: "Edit IPS per Semester",
    editGpaSubtitle: "Masukkan IPS tiap semester (0.00 - 4.00)\nIPK kumulatif dihitung otomatis.",
    editGpaSemesterLabel: "Semester",
    editGpaPlaceholder: "cth: 3.75",
    editGpaAddSemester: "Tambah Semester",
    editGpaIpkLabel: "IPK",

    homeAllSchedules: "Semua Jadwal",
    homeSearchResults: "Hasil Pencarian",
    homeTodaySchedule: "Jadwal Hari Ini",
    homeLectureSchedule: "Jadwal Kuliah",
    homeNoSchedule: "Belum ada jadwal diimpor.",
    homeNoResults: "Tidak ada hasil",
    homeNoTodaySchedule: "Tidak ada jadwal hari ini",
    homeSearchPlaceholder: "Cari mata kuliah, dosen...",
    homeTodayFilter: "Hari Ini",
    homeAllFilter: "Semua",
    homeOpenSpada: "Buka SPADA",
    homeClassCount: "kelas",
    homeOngoing: "Sedang berlangsung",
    homeNextClass: "Kelas Berikutnya",
    homeStartsNow: "Dimulai sekarang!",
    homeMinutesLeft: "menit lagi",
    homeHourLeft: "jam",
    homeOngoingLabel: "Sedang Berlangsung",

    greetingMorning: "Selamat pagi,",
    greetingAfternoon: "Selamat siang,",
    greetingEvening: "Selamat sore,",
    greetingNight: "Selamat malam,",

    tugasTitle: "Tugas & Deadline",
    tugasActive: "Aktif",
    tugasCompleted: "Selesai",
    tugasNoActive: "Tidak ada tugas aktif",
    tugasNoCompleted: "Belum ada tugas selesai",
    tugasAdd: "Tambah Tugas",
    tugasEdit: "Edit Tugas",
    tugasDeleteTitle: "Hapus tugas ini?",
    tugasDeleteAllTitle: "Hapus semua tugas selesai?",
    tugasDoneTitle: "Tugas Selesai! 🎉",
    tugasTitle2: "Judul Tugas",
    tugasDesc: "Deskripsi (opsional)",
    tugasCourse: "Mata Kuliah",
    tugasPriority: "Prioritas",
    tugasDeadline: "Deadline",
    tugasSelectCourse: "Pilih atau ketik mata kuliah",
    tugasTypeCourse: "Nama mata kuliah",

    calendarNoteLabel: "Catatan",
    calendarNoteHint: "Tulis catatan untuk hari ini...",
    calendarColorLabel: "Warna",

    onboardingWelcome: "Selamat datang! 👋",
    onboardingNameHint: "Masukkan nama Anda",
    onboardingNameLabel: "Nama Anda",
    onboardingNameError: "Nama tidak boleh kosong",
    onboardingNext: "Lanjutkan",
    onboardingStart: "Mulai Sekarang",
    onboardingPage1Title: "Import Jadwal",
    onboardingPage1Desc: "Salin jadwal dari portal akademik, lalu paste ke Spader. Spader akan otomatis membaca semua mata kuliahmu.",
    onboardingPage1Tip: "Format yang didukung: tabel jadwal dari sistem SPADA / portal akademik kampus.",
    onboardingPage2Title: "Notifikasi Otomatis",
    onboardingPage2Desc: "Aktifkan notifikasi agar Spader mengingatkan kamu sebelum kelas dimulai. Atur berapa menit sebelumnya di Pengaturan.",
    onboardingPage2Tip: "Kamu bisa set 15, 30, atau 60 menit sebelum kelas. Bisa juga atur beberapa reminder sekaligus.",
    onboardingPage3Title: "Widget & Lebih Banyak",
    onboardingPage3Desc: "Tambahkan widget ke home screen atau lock screen untuk lihat jadwal hari ini tanpa buka app.",
    onboardingPage3Tip: "Ada juga kalender, pencatatan IPK per semester, dan warna kustom per mata kuliah.",

    dayMonday: "Senin",
    dayTuesday: "Selasa",
    dayWednesday: "Rabu",
    dayThursday: "Kamis",
    dayFriday: "Jumat",
    daySaturday: "Sabtu",
    daySunday: "Minggu",

    dayShortSun: "Min",
    dayShortMon: "Sen",
    dayShortTue: "Sel",
    dayShortWed: "Rab",
    dayShortThu: "Kam",
    dayShortFri: "Jum",
    dayShortSat: "Sab",

    months: ["Januari","Februari","Maret","April","Mei","Juni",
             "Juli","Agustus","September","Oktober","November","Desember"],

    aboutDeveloper: "Developer",
    aboutEmail: "Email",
    aboutVersion: "Versi",
    aboutPlatform: "Platform",
    aboutMadeFor: "Dibuat untuk",

    courseDetailSchedule: "Jadwal",
    courseDetailLecturer: "Dosen",
    importHint: "Salin teks dari portal akademik (SPADA), lalu paste di bawah ini.",
    importPlaceholder: "Paste teks jadwal di sini...",
    importTitle: "Import Jadwal",
    manageScheduleTitle: "Kelola Jadwal",
    manageScheduleEmpty: "Belum ada jadwal.",
    editNameTitle: "Edit Nama",
    editNameLabel: "Nama",
    profileTitle: "Profil",
    notifTitle: "Pengaturan Notifikasi"
)

let EnglishStrings = AppStrings(
    navHome: "Home",
    navTugas: "Tasks",
    navCalendar: "Calendar",
    navSettings: "Settings",

    settingsStudentSubtitle: "Student of UPN Veteran Yogyakarta",
    settingsGpaChart: "GPA Chart",
    settingsNoGpaData: "No GPA data yet",
    settingsAddGpa: "+ Add GPA",
    settingsManageSchedule: "Manage Schedule",
    settingsAppearance: "Appearance",
    settingsNotification: "Notification Settings",
    settingsNotificationSubtitle: "Set class schedule reminders",
    settingsAbout: "About App",
    settingsReset: "Reset App",
    settingsResetTitle: "Reset App?",
    settingsResetBody: "All data will be deleted and the app will close.",
    settingsLanguage: "Language",
    settingsLanguageSubtitle: "Choose display language",

    langIndonesia: "Indonesia",
    langEnglish: "English",

    appearanceTitle: "Appearance",
    appearanceSystem: "System",
    appearanceLight: "Light",
    appearanceDark: "Dark",

    actionSave: "Save",
    actionCancel: "Cancel",
    actionReset: "Reset",
    actionDelete: "Delete",
    actionDeleteAll: "Delete All",
    actionClose: "Close",
    actionImport: "Import",
    actionOK: "OK",
    actionAdd: "Add",

    editGpaTitle: "Edit GPA per Semester",
    editGpaSubtitle: "Enter GPA per semester (0.00 - 4.00)\nCumulative GPA is calculated automatically.",
    editGpaSemesterLabel: "Semester",
    editGpaPlaceholder: "e.g. 3.75",
    editGpaAddSemester: "Add Semester",
    editGpaIpkLabel: "Cumulative GPA",

    homeAllSchedules: "All Schedules",
    homeSearchResults: "Search Results",
    homeTodaySchedule: "Today's Schedule",
    homeLectureSchedule: "Lecture Schedule",
    homeNoSchedule: "No schedule imported yet.",
    homeNoResults: "No results",
    homeNoTodaySchedule: "No schedule today",
    homeSearchPlaceholder: "Search course, lecturer...",
    homeTodayFilter: "Today",
    homeAllFilter: "All",
    homeOpenSpada: "Open SPADA",
    homeClassCount: "classes",
    homeOngoing: "Ongoing",
    homeNextClass: "Next Class",
    homeStartsNow: "Starting now!",
    homeMinutesLeft: "min left",
    homeHourLeft: "hr",
    homeOngoingLabel: "Ongoing",

    greetingMorning: "Good morning,",
    greetingAfternoon: "Good afternoon,",
    greetingEvening: "Good evening,",
    greetingNight: "Good night,",

    tugasTitle: "Tasks & Deadlines",
    tugasActive: "Active",
    tugasCompleted: "Done",
    tugasNoActive: "No active tasks",
    tugasNoCompleted: "No completed tasks yet",
    tugasAdd: "Add Task",
    tugasEdit: "Edit Task",
    tugasDeleteTitle: "Delete this task?",
    tugasDeleteAllTitle: "Delete all completed tasks?",
    tugasDoneTitle: "Task Done! 🎉",
    tugasTitle2: "Task Title",
    tugasDesc: "Description (optional)",
    tugasCourse: "Course",
    tugasPriority: "Priority",
    tugasDeadline: "Deadline",
    tugasSelectCourse: "Select or type course",
    tugasTypeCourse: "Course name",

    calendarNoteLabel: "Note",
    calendarNoteHint: "Write a note for today...",
    calendarColorLabel: "Color",

    onboardingWelcome: "Welcome! 👋",
    onboardingNameHint: "Enter your name",
    onboardingNameLabel: "Your name",
    onboardingNameError: "Name cannot be empty",
    onboardingNext: "Continue",
    onboardingStart: "Get Started",
    onboardingPage1Title: "Import Schedule",
    onboardingPage1Desc: "Copy your schedule from the academic portal and paste it into Spader. Spader will automatically read all your courses.",
    onboardingPage1Tip: "Supported format: schedule table from SPADA / campus academic portal.",
    onboardingPage2Title: "Automatic Notifications",
    onboardingPage2Desc: "Enable notifications so Spader reminds you before class starts. Set how many minutes before in Settings.",
    onboardingPage2Tip: "You can set 15, 30, or 60 minutes before class, or multiple reminders at once.",
    onboardingPage3Title: "Widget & More",
    onboardingPage3Desc: "Add a widget to your home screen or lock screen to see today's schedule without opening the app.",
    onboardingPage3Tip: "There's also a calendar, GPA tracking per semester, and custom colors per course.",

    dayMonday: "Monday",
    dayTuesday: "Tuesday",
    dayWednesday: "Wednesday",
    dayThursday: "Thursday",
    dayFriday: "Friday",
    daySaturday: "Saturday",
    daySunday: "Sunday",

    dayShortSun: "Sun",
    dayShortMon: "Mon",
    dayShortTue: "Tue",
    dayShortWed: "Wed",
    dayShortThu: "Thu",
    dayShortFri: "Fri",
    dayShortSat: "Sat",

    months: ["January","February","March","April","May","June",
             "July","August","September","October","November","December"],

    aboutDeveloper: "Developer",
    aboutEmail: "Email",
    aboutVersion: "Version",
    aboutPlatform: "Platform",
    aboutMadeFor: "Made for",

    courseDetailSchedule: "Schedule",
    courseDetailLecturer: "Lecturer",
    importHint: "Copy text from the academic portal (SPADA), then paste it below.",
    importPlaceholder: "Paste schedule text here...",
    importTitle: "Import Schedule",
    manageScheduleTitle: "Manage Schedule",
    manageScheduleEmpty: "No schedules yet.",
    editNameTitle: "Edit Name",
    editNameLabel: "Name",
    profileTitle: "Profile",
    notifTitle: "Notification Settings"
)
