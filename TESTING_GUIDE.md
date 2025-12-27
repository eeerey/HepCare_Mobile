# Panduan Penggunaan & Testing Menu Profil

## 🎯 Ringkas Fitur

| Menu                         | Fungsi                                 | File                            |
| ---------------------------- | -------------------------------------- | ------------------------------- |
| **Setting**                  | Atur tema, suara, getaran, hapus cache | `settings.dart`                 |
| **Notification Preferences** | Kelola notifikasi artikel              | `notification_preferences.dart` |
| **About App**                | Info aplikasi dan fitur                | `about_app.dart`                |
| **Help & FAQ**               | Bantuan dan pertanyaan umum            | `help_faq.dart`                 |

## 📋 Checklist Implementasi

### ✅ File yang Dibuat

- [x] `lib/notification_service.dart` - Service untuk notifikasi
- [x] `lib/settings.dart` - Settings screen
- [x] `lib/notification_preferences.dart` - Notification preferences screen
- [x] `lib/about_app.dart` - About app screen
- [x] `lib/help_faq.dart` - Help & FAQ screen

### ✅ Update di Profile

- [x] Import 4 file baru
- [x] Tambah navigation ke Settings
- [x] Tambah navigation ke Notification Preferences
- [x] Tambah navigation ke About App
- [x] Tambah navigation ke Help & FAQ

### ✅ Data Persistence

- [x] SharedPreferences untuk menyimpan preferences
- [x] Auto-load settings saat screen dibuka
- [x] Auto-save saat user mengubah setting

## 🧪 Testing Guide

### Test 1: Settings Screen

```
1. Buka Profile → Klik "Setting"
2. Test mode gelap:
   - Toggle "Mode Gelap" ON/OFF
   - Verifikasi toggle berubah
3. Test suara:
   - Toggle "Suara" ON/OFF
4. Test getaran:
   - Toggle "Getaran" ON/OFF
5. Test hapus cache:
   - Klik "Hapus Cache Data"
   - Dialog muncul dengan konfirmasi
   - Klik "Hapus" atau "Batal"
6. Keluar aplikasi dan masuk kembali
   - Verifikasi semua setting masih tersimpan ✓
```

### Test 2: Notification Preferences

```
1. Buka Profile → Klik "Notification Preferences"
2. Test main toggle:
   - Verifikasi loading spinner saat load
   - Toggle "Aktifkan Notifikasi" ON
   - SnackBar muncul: "Notifikasi diaktifkan"
3. Test article counter:
   - Seharusnya menampilkan "Ada X artikel baru"
   - (Jika tidak ada artikel baru, nilai 0)
4. Test notification types:
   - Saat toggle notifikasi OFF:
     - Type items harus disabled (greyed out)
     - Toggle tidak bisa diubah
   - Saat toggle notifikasi ON:
     - Type items bisa diubah
5. Test info box:
   - Info box seharusnya selalu visible
6. Test contact support:
   - Scroll ke bawah, lihat contact info
7. Keluar aplikasi minimal 15 menit
   - Verify periodic check berjalan (check logs/debugger)
   - Jika ada artikel baru, check updated counter saat buka kembali
```

### Test 3: About App

```
1. Buka Profile → Klik "Tentang Aplikasi"
2. Verifikasi tampilan:
   - Logo visible dengan background biru
   - Teks "HepCare v1.0.0" terang
   - Section "Tentang HepCare" terisi dengan deskripsi
   - Section "Fitur Utama" menampilkan 4 fitur dengan icon
3. Scroll down dan verifikasi:
   - Informasi Pengembang (Version, Platform, etc.)
   - Pemberitahuan Hukum
   - Link Privacy Policy & ToS
4. Verifikasi scroll behavior smooth
```

### Test 4: Help & FAQ Screen

```
1. Buka Profile → Klik "Bantuan & FAQ"
2. Test search functionality:
   - Type "kuis" di search box
   - Hanya pertanyaan tentang "Kuis Kesehatan" yang tampil
   - Clear search, semua FAQ kembali
3. Test category filter:
   - Filter "Semua" - 10 items tampil
   - Filter "Kuis Kesehatan" - 2 items tampil
   - Filter "Riwayat Pemeriksaan" - 1 item tampil
   - Dst untuk kategori lain
4. Test expandable items:
   - Klik FAQ item, harus expand
   - Klik lagi, harus collapse
   - Verifikasi text terformat dengan baik
5. Test contact support section:
   - Scroll ke bawah
   - Verifikasi email dan nomor telepon visible
```

### Test 5: Navigation Flow

```
1. Dari Profile:
   - Klik Setting → SettingsScreen muncul
   - Klik back → kembali ke Profile ✓
2. Dari Setting:
   - Klik back → kembali ke Profile ✓
3. Dari Notification Preferences:
   - Klik back → kembali ke Profile ✓
4. Dari About App:
   - Klik back → kembali ke Profile ✓
5. Dari Help & FAQ:
   - Klik back → kembali ke Profile ✓
6. Verifikasi tidak ada navigation stack issue
```

## 🔧 Debugging Tips

### Jika settings tidak tersimpan:

```dart
// Check SharedPreferences di console
// Tambah debug print di _saveSettings()
Future<void> _saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  print('Saving: dark_mode=$_isDarkMode');
  await prefs.setBool('dark_mode', _isDarkMode);
  print('Saved!');
}
```

### Jika notifikasi tidak update:

```dart
// Check NotificationService timer
// Tambah debug print di _startPeriodicCheck()
void _startPeriodicCheck() {
  print('Starting periodic check every 15 minutes');
  _periodicTimer = Timer.periodic(const Duration(minutes: 15), (_) {
    print('Running periodic check...');
    checkForNewArticles();
  });
}

// Test immediate check
await NotificationService.checkForNewArticles();
```

### Jika FAQ tidak filter:

```dart
// Check filter logic
print('Selected category: $selectedCategory');
print('Filtered items: ${filteredFAQ.length}');
```

## 🎨 UI/UX Testing

### Visual Consistency

- [ ] Semua screen punya header dengan back button
- [ ] Semua screen background warna primaryLightBlue (#E3F2FD)
- [ ] Semua container warna putih dengan shadow
- [ ] Font sizes konsisten (28, 16, 14, 13, 12)
- [ ] Spacing konsisten

### Responsiveness

- [ ] Test di landscape mode
- [ ] Test di berbagai ukuran screen
- [ ] Verifikasi scrolling smooth di content panjang
- [ ] Verifikasi padding/margin tepat

### Performance

- [ ] Tidak ada freeze saat membuka screen
- [ ] Loading spinner berjalan smooth
- [ ] API calls tidak blocking UI

## 📱 Device Testing

### Test di Emulator Android

```
1. Run flutter app
2. Verifikasi semua screen bisa diakses
3. Test tombol back (back navigation)
4. Test notification periodic check
```

### Test di Emulator iOS

```
1. Sama seperti Android
2. Verifikasi UI cocok dengan iOS design patterns
```

### Test di Device Fisik

```
1. Install APK/IPA
2. Full user flow testing
3. Check performance dan responsiveness
```

## 🔔 Notifikasi Testing Detail

### Setup untuk test notifikasi:

```dart
// Dalam initState NotificationPreferencesScreen
Future<void> _testNotification() async {
  // Langsung test check function
  final count = await NotificationService.getNewArticleCount();
  print('New articles count: $count');
}

// Panggil dari button di screen
FloatingActionButton(
  onPressed: _testNotification,
  child: Icon(Icons.notification_important),
)
```

### Simulate artikel baru:

```
1. Add artikel di backend API sebelum test
2. Pastikan artikel date lebih baru dari last_check_time
3. Tunggu atau trigger immediate check
4. Verifikasi counter bertambah
```

## 📊 Expected Behavior

### Settings Screen

- Semua toggle switch berfungsi ✓
- Data tersimpan setelah close/reopen ✓
- Delete cache dialog muncul dan berfungsi ✓

### Notification Preferences

- Loading state di awal ✓
- Toggle main notifikasi enable/disable type items ✓
- Article counter update sesuai API response ✓
- SnackBar muncul saat toggle utama ✓

### About App

- Logo dan text ditampilkan ✓
- Scroll smooth ✓
- Semua section visible ✓

### Help & FAQ

- Search filter berfungsi real-time ✓
- Category filter berfungsi ✓
- FAQ items expandable ✓
- Contact info visible ✓

## ✅ Pre-Release Checklist

- [ ] Semua 4 screen dapat diakses dari Profile
- [ ] Semua navigation back button berfungsi
- [ ] SharedPreferences persist data dengan benar
- [ ] UI responsive di berbagai ukuran screen
- [ ] Tidak ada warning/error di console
- [ ] Notifikasi check berjalan (bisa di-test dengan debug timer 1 menit)
- [ ] Performance baik saat membuka screen
- [ ] Styling konsisten di semua halaman

## 🚀 Next Steps (Future Enhancement)

1. **Firebase Cloud Messaging (FCM)**

   - Push notification real-time
   - No need for periodic polling

2. **flutter_local_notifications**

   - Local notification dengan sound & vibration
   - Better UX

3. **Backend Optimization**

   - `/api/articles/new` endpoint khusus
   - Filter by created_at > last_check

4. **More Settings**

   - Font size preference
   - Language setting
   - Notification frequency

5. **Analytics**
   - Track menu usage
   - Track notification engagement

---

**Catatan Penting:**

- Semua data preference tersimpan di SharedPreferences (local storage)
- Notifikasi artikel menggunakan periodic timer 15 menit
- Untuk production, gunakan FCM untuk real-time notifications
- Test thorough sebelum release ke production

Selamat testing! 🎉
