# Spader

Spader adalah aplikasi manajemen jadwal kuliah berbasis iOS, dibuat khusus untuk mahasiswa UPN "Veteran" Yogyakarta. Aplikasi ini membantu kamu mengelola jadwal kuliah, tugas, dan catatan akademik dalam satu tempat — dengan tampilan yang bersih, notifikasi pintar, dan dukungan dua bahasa.

---

## Screenshots

<p align="center">
  <img src="docs/screenshots/lecture_schedule.jpeg" width="18%" />
  <img src="docs/screenshots/lecture_schedule_today.jpeg" width="18%" />
  <img src="docs/screenshots/tasks.jpeg" width="18%" />
  <img src="docs/screenshots/calendar.jpeg" width="18%" />
  <img src="docs/screenshots/profile_interface.jpeg" width="18%" />
</p>

<p align="center">
  <img src="docs/screenshots/calendar_date_interface.jpeg" width="18%" />
  <img src="docs/screenshots/notification_settings.jpeg" width="18%" />
  <img src="docs/screenshots/appearance_settings.jpeg" width="18%" />
</p>

---

## Fitur

### Jadwal Kuliah
- Tampilkan seluruh jadwal kuliah yang dikelompokkan per hari
- Filter jadwal untuk melihat kuliah hari ini saja
- Highlight otomatis kelas yang sedang berlangsung atau akan dimulai berikutnya
- Pencarian jadwal berdasarkan nama mata kuliah atau dosen
- Setiap mata kuliah memiliki warna unik yang bisa dikustomisasi
- Detail kuliah: nama matkul, dosen, ruangan, dan catatan pribadi

### Input Jadwal
- Import jadwal otomatis dari teks (format SIAKAD / copy-paste)
- Input manual per mata kuliah jika diperlukan
- Edit dan hapus jadwal kapan saja

### Manajemen Tugas
- Tambah tugas dengan judul, deskripsi, mata kuliah, deadline, dan prioritas (Rendah / Sedang / Tinggi)
- Status tugas otomatis: Aktif, Selesai, atau Terlambat
- Indikator waktu tersisa (menit, jam, hari)
- Notifikasi pengingat deadline tugas dengan aksi "Tandai Selesai" langsung dari notifikasi
- Filter tugas berdasarkan status

### Kalender
- Tampilan kalender bulanan
- Tambah catatan pada tanggal tertentu
- Lihat jadwal kuliah yang terjadwal pada hari yang dipilih

### Profil & IPK
- Input nama pengguna dengan foto profil
- Catat IPK per semester
- Grafik perkembangan IPK antar semester (menggunakan Swift Charts)

### Notifikasi
- Notifikasi pengingat sebelum kuliah dimulai
- Konfigurasi jumlah pengingat (1–5 kali) dan jarak waktu antar pengingat
- Notifikasi deadline tugas yang bisa langsung ditandai selesai

### Tampilan & Bahasa
- Dukungan mode gelap / terang / ikut sistem
- Bilingual: Bahasa Indonesia dan English
- Gradient background adaptif sesuai color scheme

### iOS Widget
- Widget layar utama yang menampilkan jadwal kuliah hari ini

---

## Tech Stack

| Komponen | Detail |
|---|---|
| Platform | iOS 17+ |
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Data Persistence | `UserDefaults` via `@AppStorage` |
| Notifications | `UserNotifications` framework |
| Charts | Swift Charts |
| Widget | WidgetKit |
| Hot Reload (Dev) | [HotSwiftUI](https://github.com/johnno1962/HotSwiftUI) |

---

## Struktur Proyek

```
spader/
├── spader.xcodeproj/
├── spader/
│   ├── App/
│   │   └── spaderApp.swift
│   ├── Core/
│   │   ├── Extensions/
│   │   │   ├── Color.swift
│   │   │   └── Date.swift
│   │   ├── i18n/
│   │   │   ├── AppStrings.swift
│   │   │   └── LanguageManager.swift
│   │   ├── Managers/
│   │   │   ├── NotificationManager.swift
│   │   │   ├── ScheduleManager.swift
│   │   │   └── TugasManager.swift
│   │   ├── Models/
│   │   │   ├── AppearanceMode.swift
│   │   │   ├── CalendarNote.swift
│   │   │   ├── JadwalKuliah.swift
│   │   │   ├── SemesterGPA.swift
│   │   │   └── Tugas.swift
│   │   └── Services/
│   │       ├── NotificationParser.swift
│   │       ├── NotificationScheduler.swift
│   │       ├── ScheduleParser.swift
│   │       ├── StorageService.swift
│   │       └── TextInputParser.swift
│   ├── Features/
│   │   ├── Calendar/
│   │   │   └── Views/
│   │   │       ├── CalendarView.swift
│   │   │       └── Components/
│   │   │           ├── DayCell.swift
│   │   │           ├── NoteRow.swift
│   │   │           └── NoteSheetView.swift
│   │   ├── CourseDetail/
│   │   │   └── Views/
│   │   │       ├── CourseDetailView.swift
│   │   │       └── Components/
│   │   │           └── InfoRow.swift
│   │   ├── Home/
│   │   │   └── Views/
│   │   │       ├── HomeView.swift
│   │   │       └── Components/
│   │   │           ├── DaySection.swift
│   │   │           └── ScheduleCard.swift
│   │   ├── Onboarding/
│   │   │   └── Views/
│   │   │       ├── OnboardingView.swift
│   │   │       └── SplashScreenView.swift
│   │   ├── Settings/
│   │   │   └── Views/
│   │   │       ├── AppearanceSettingsView.swift
│   │   │       ├── ManageScheduleView.swift
│   │   │       ├── NotificationSettingsView.swift
│   │   │       ├── ProfileView.swift
│   │   │       ├── SettingsView.swift
│   │   │       └── Components/
│   │   └── Tugas/
│   │       └── Views/
│   │           ├── TugasView.swift
│   │           ├── AddEditTugasView.swift
│   │           └── Components/
│   │               └── TugasCard.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   └── Sounds/
│   │       └── bell.aif
│   ├── Shared/
│   │   ├── Components/
│   │   │   ├── GradientBackground.swift
│   │   │   ├── SectionCard.swift
│   │   │   ├── SectionFooter.swift
│   │   │   ├── SectionHeader.swift
│   │   │   └── ToastView.swift
│   │   ├── Utils/
│   │   │   └── ImagePicker.swift
│   │   └── Views/
│   │       └── MainView.swift
│   └── Widget/
│       ├── SpaderWidget.swift
│       └── SpaderWidgetBundle.swift
├── SpaderWidget/
│   ├── SpaderWidgetControl.swift
│   ├── SpaderWidgetLiveActivity.swift
│   └── Assets.xcassets/
├── HotSwiftUI/               ← submodule (dev only)
└── docs/
    └── screenshots/
        ├── lecture_schedule.jpeg
        ├── lecture_schedule_today.jpeg
        ├── tasks.jpeg
        ├── calendar.jpeg
        ├── calendar_date_interface.jpeg
        ├── profile_interface.jpeg
        ├── notification_settings.jpeg
        └── appearance_settings.jpeg
```

---

## File yang Perlu Di-upload ke GitHub

Yang **wajib** di-upload:

```
spader/                          # folder utama proyek
├── spader.xcodeproj/            # file proyek Xcode
├── spader/                      # source code aplikasi (semua folder di dalam ini)
├── SpaderWidget/                # source code widget
├── spader.entitlements
├── SpaderWidgetExtension.entitlements
└── docs/
    └── screenshots/             # screenshot untuk README
```

Yang **tidak perlu** di-upload (tambahkan ke `.gitignore`):

```
spader_backup/                   # folder backup lama
spader.zip                       # arsip zip di dalam folder
HotSwiftUI/                      # dependency dev, pakai submodule atau hapus saja
*.xcuserstate
xcuserdata/
.DS_Store
```

> Pastikan folder `docs/screenshots/` kamu buat di repo dan upload semua file `.jpeg` dari zip screenshots ke sana, supaya gambar di README muncul dengan benar.

---

## Cara Build

1. Clone repo ini
2. Buka `spader.xcodeproj` di Xcode 15+
3. Pilih target device atau simulator (iOS 17+)
4. Build & Run (`Cmd + R`)

Tidak ada dependency eksternal yang perlu di-install via SPM — semua sudah tercakup di dalam proyek.

---

## Developer

Dibuat oleh **Wildan Rifqi** — Mahasiswa Informatika, UPN "Veteran" Yogyakarta.
