<p align="center">
  <img src="docs/icon.jpg" width="120" style="border-radius: 22px;" />
</p>

<h1 align="center">Spader</h1>

<p align="center">
  Aplikasi manajemen jadwal kuliah untuk mahasiswa UPN "Veteran" Yogyakarta
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17%2B-black?logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftUI-blue?logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/WidgetKit-supported-purple" />
  <img src="https://img.shields.io/badge/license-MIT-green" />
</p>

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

---

## Cara Build

1. Clone repo ini
2. Buka `spader.xcodeproj` di Xcode 15+
3. Pilih target device atau simulator (iOS 17+)
4. Build & Run (`Cmd + R`)

Tidak ada dependency eksternal yang perlu di-install via SPM, semua sudah tercakup di dalam proyek.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Developer

Dibuat oleh **Wildan Rifqi** — Mahasiswa Informatika, UPN "Veteran" Yogyakarta.
