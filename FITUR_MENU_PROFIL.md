# Fitur Menu Profil & Notifikasi - Implementasi Lengkap

## 📋 Ringkasan Fitur yang Ditambahkan

Anda sekarang memiliki sistem menu profil yang lengkap dengan 4 halaman tambahan dan layanan notifikasi untuk artikel terbaru.

## 🎯 Fitur-Fitur Baru

### 1. **Pengaturan (Settings)**

**File:** `lib/settings.dart`

Halaman untuk mengatur preferensi aplikasi:

- 🌓 **Mode Gelap** - Toggle untuk mengubah tema aplikasi (simpan dengan SharedPreferences)
- 🔔 **Notifikasi Umum** - Aktifkan/nonaktifkan notifikasi secara keseluruhan
- 🔊 **Suara** - Aktifkan/nonaktifkan suara notifikasi
- 📳 **Getaran** - Aktifkan/nonaktifkan getaran notifikasi
- 🗑️ **Hapus Cache Data** - Bersihkan data sementara dengan konfirmasi dialog

Fitur:

- Semua preferensi tersimpan di SharedPreferences
- UI yang intuitif dengan toggle switches
- Grouping pengaturan per kategori (Tampilan, Notifikasi, Informasi)

### 2. **Preferensi Notifikasi (Notification Preferences)**

**File:** `lib/notification_preferences.dart`

Halaman khusus untuk mengatur notifikasi:

- ✅ **Toggle Notifikasi Utama** - Aktifkan/nonaktifkan semua notifikasi
- 📰 **Artikel Terbaru** - Terima notifikasi untuk artikel kesehatan baru
- ⏰ **Pengingat Pemeriksaan** - Terima pengingat untuk pemeriksaan rutin
- ⚠️ **Notifikasi Penting** - Terima pemberitahuan informasi penting

Fitur khusus:

- Menampilkan jumlah artikel terbaru yang belum dibaca
- Integrasi dengan `NotificationService` untuk pengecekan artikel
- Info box dengan tips penggunaan notifikasi
- Item notifikasi dapat dinonaktifkan jika notifikasi utama dimatikan

### 3. **Tentang Aplikasi (About App)**

**File:** `lib/about_app.dart`

Halaman informasi aplikasi:

- 📱 **Logo & Informasi Dasar** - Logo HepCare v1.0.0
- ✨ **Tentang HepCare** - Deskripsi aplikasi dan tujuannya
- 🎯 **Fitur Utama** - Daftar 4 fitur utama dengan ikon:
  - Kuis Kesehatan
  - Riwayat Pemeriksaan
  - Peta Rumah Sakit
  - Artikel Kesehatan
- ℹ️ **Informasi Pengembang** - Versi, platform, sistem operasi, lisensi
- ⚖️ **Pemberitahuan Hukum** - Disclaimer tentang penggunaan aplikasi
- 🔗 **Link Penting** - Kebijakan Privasi & Syarat & Ketentuan

### 4. **Bantuan & FAQ (Help & FAQ)**

**File:** `lib/help_faq.dart`

Halaman bantuan komprehensif dengan 10 pertanyaan umum:

**Kategori:**

1. **Kuis Kesehatan** - Cara mengisi kuis dan arti tingkat risiko
2. **Riwayat Pemeriksaan** - Cara melihat riwayat
3. **Profil & Pengaturan** - Cara mengubah data profil
4. **Notifikasi** - Cara mengaktifkan notifikasi
5. **Pemetaan** - Cara menemukan rumah sakit
6. **Keamanan & Privasi** - Keamanan data
7. **Dukungan** - Cara menghubungi support
8. **Akun** - Logout dan penghapusan akun

**Fitur:**

- 🔍 **Search Bar** - Cari pertanyaan berdasarkan kata kunci
- 🏷️ **Filter Kategori** - Filter FAQ berdasarkan kategori
- 📂 **Expandable Items** - Pertanyaan bisa dikembangkan untuk melihat jawaban
- 📧 **Contact Support** - Informasi kontak dukungan pelanggan

### 5. **Layanan Notifikasi (Notification Service)**

**File:** `lib/notification_service.dart`

Backend service untuk mengelola notifikasi artikel:

**Fitur Utama:**

- **initialize()** - Inisialisasi layanan notifikasi
- **checkForNewArticles()** - Cek artikel baru secara berkala
- **isNotificationEnabled()** - Cek status notifikasi
- **setNotificationEnabled(bool)** - Aktifkan/nonaktifkan notifikasi
- **getNewArticleCount()** - Hitung jumlah artikel baru
- **getLatestArticles()** - Ambil daftar artikel terbaru

**Cara Kerja:**

1. Pengecekan dilakukan setiap 15 menit (Timer.periodic)
2. Membandingkan waktu artikel dengan `last_article_check` di SharedPreferences
3. Hanya mengirim notifikasi jika ada artikel lebih baru dari pengecekan terakhir
4. Menyimpan waktu pengecekan terakhir untuk perbandingan berikutnya

## 🔧 Integrasi ke Profile.dart

Update di `lib/profile.dart`:

```dart
// Import file-file baru
import 'settings.dart';
import 'notification_preferences.dart';
import 'about_app.dart';
import 'help_faq.dart';

// Navigation setup untuk setiap menu
ProfileMenuItem(
  icon: Icons.settings_outlined,
  title: 'Setting',
  onTap: () {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  },
),

ProfileMenuItem(
  icon: Icons.notifications_none,
  title: 'Notification Preferences',
  onTap: () {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const NotificationPreferencesScreen()),
    );
  },
),

// ... dan seterusnya untuk About App dan Help & FAQ
```

## 💾 Penyimpanan Data

Data tersimpan di **SharedPreferences** dengan key:

- `dark_mode` - Status mode gelap (bool)
- `sound_enabled` - Status suara notifikasi (bool)
- `vibration_enabled` - Status getaran (bool)
- `notifications_enabled` - Status notifikasi utama (bool)
- `last_article_check` - Waktu pengecekan artikel terakhir (ISO8601 string)

## 🚀 Cara Menggunakan

### Mengaktifkan Notifikasi di Profile:

1. Buka **Profil** → **Notification Preferences**
2. Aktifkan toggle **"Aktifkan Notifikasi"**
3. Pilih tipe notifikasi yang ingin diterima
4. Aplikasi akan mulai cek artikel setiap 15 menit

### Mengakses Menu Baru:

- **Settings** - Atur tema, suara, getaran, hapus cache
- **Notification Preferences** - Kelola notifikasi artikel
- **About App** - Info aplikasi dan fitur
- **Help & FAQ** - Bantuan dan pertanyaan umum

## 📝 Next Steps (Opsional)

Untuk implementasi yang lebih lengkap:

1. **Integrasi Firebase Cloud Messaging (FCM)**

   - Push notification real-time ke device
   - Lebih efisien daripada periodic polling

2. **Local Notifications**

   - Install package: `flutter_local_notifications`
   - Tampilkan notifikasi lokal dengan suara dan getaran real-time

3. **Backend Integration**

   - Buat endpoint `/api/articles/new` untuk filter artikel terbaru
   - Optimasi pengecekan dengan timestamp

4. **More Settings Options**
   - Pilihan interval pengecekan (5, 15, 30 menit)
   - Pilihan jam untuk tidak mengganggu (Do Not Disturb)

## 🎨 Styling Konsistensi

Semua halaman menggunakan:

- **Color:**

  - `hepCareBlue = Color(0xFF1E88E5)` - Primary color
  - `primaryLightBlue = Color(0xFFE3F2FD)` - Background
  - `hepCareGreen = Color(0xFF4CAF50)` - Accent/Success

- **Layout:**
  - Unified header dengan back button
  - Container dengan rounded corners dan shadow
  - Responsive padding dan spacing

## ✅ Fitur Selesai

✅ Menu Profil yang Lengkap
✅ 4 Halaman Tambahan (Settings, Notifications, About, Help)
✅ Layanan Notifikasi dengan Pengecekan Berkala
✅ Penyimpanan Preferensi di SharedPreferences
✅ UI/UX yang Konsisten dan Intuitif
✅ Integrasi dengan Halaman Profil Existing

---

**Catatan:** Semua halaman sudah siap digunakan. Untuk fitur notifikasi real-time yang lebih baik, pertimbangkan untuk mengintegrasikan Firebase Cloud Messaging atau flutter_local_notifications di masa depan.
