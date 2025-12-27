# Arsitektur Menu Profil & Notifikasi

## 📊 Diagram Alur Navigasi

```
ProfileScreen
    ├── Edit Profile → EditProfileScreen
    ├── Setting → SettingsScreen
    │   ├── Mode Gelap (dark_mode)
    │   ├── Suara (sound_enabled)
    │   ├── Getaran (vibration_enabled)
    │   ├── Notifikasi (notifications_enabled) → update NotificationService
    │   └── Hapus Cache
    │
    ├── Notification Preferences → NotificationPreferencesScreen
    │   ├── Toggle Notifikasi Utama → start/stop periodic check
    │   ├── Artikel Terbaru (article_notifications)
    │   ├── Pengingat Pemeriksaan (reminder_notifications)
    │   ├── Notifikasi Penting (urgent_notifications)
    │   └── Menampilkan jumlah artikel baru
    │
    ├── About App → AboutAppScreen
    │   ├── Logo & Versi
    │   ├── Deskripsi Aplikasi
    │   ├── Fitur Utama (4 items)
    │   ├── Info Pengembang
    │   ├── Pemberitahuan Hukum
    │   └── Link (Privacy Policy, ToS)
    │
    ├── Help & FAQ → HelpFaqScreen
    │   ├── Search Bar (filter by text)
    │   ├── Category Filter (Semua, Kuis Kesehatan, Riwayat, dll)
    │   ├── 10 FAQ Items (expandable)
    │   └── Contact Support Info
    │
    └── Log Out
```

## 🔄 Data Flow untuk Notifikasi

```
User Aktifkan Notifikasi
        ↓
setNotificationEnabled(true)
        ↓
SharedPreferences.setBool('notifications_enabled', true)
        ↓
NotificationService.initialize()
        ↓
Timer.periodic(15 minutes) ← _startPeriodicCheck()
        ↓
checkForNewArticles()
        ↓
GET /api/artikel (with auth token)
        ↓
Parse JSON & compare dates dengan last_article_check
        ↓
Jika ada artikel baru:
   - Count = jumlah artikel lebih baru
   - Simpan last_article_check = now()
   - Debug print: "📢 NOTIFIKASI: Ada X artikel terbaru..."
   (Dalam implementasi nyata: gunakan FCM atau flutter_local_notifications)
```

## 📦 File Structure

```
lib/
├── profile.dart ✨ (Updated with imports & navigation)
├── settings.dart ✨ (NEW)
├── notification_preferences.dart ✨ (NEW)
├── notification_service.dart ✨ (NEW)
├── about_app.dart ✨ (NEW)
├── help_faq.dart ✨ (NEW)
├── ... (existing files)
```

## 🔐 SharedPreferences Keys

| Key                     | Type             | Default | Used By                                            |
| ----------------------- | ---------------- | ------- | -------------------------------------------------- |
| `dark_mode`             | bool             | false   | SettingsScreen                                     |
| `sound_enabled`         | bool             | true    | SettingsScreen                                     |
| `vibration_enabled`     | bool             | true    | SettingsScreen                                     |
| `notifications_enabled` | bool             | false   | NotificationService, NotificationPreferencesScreen |
| `last_article_check`    | String (ISO8601) | null    | NotificationService                                |
| `jwt_token`             | String           | -       | (existing)                                         |
| `access_token`          | String           | -       | (existing)                                         |

## 🎨 Component Breakdown

### SettingsScreen

```dart
- _isDarkMode: bool
- _soundEnabled: bool
- _vibrationEnabled: bool
- _notificationsEnabled: bool

Methods:
- _loadSettings() → Load dari SharedPreferences
- _saveSettings() → Save ke SharedPreferences
- _showClearCacheDialog() → Show confirmation dialog

Widgets:
- SettingsTile (untuk settings dengan toggle)
- SettingsAction (untuk action items seperti "Hapus Cache")
```

### NotificationPreferencesScreen

```dart
- _isLoading: bool
- _notificationsEnabled: bool
- _articleNotifications: bool
- _reminderNotifications: bool
- _urgentNotifications: bool
- _newArticleCount: int

Methods:
- _loadPreferences() → Load notification status
- _checkNewArticles() → Get count dari NotificationService

Widgets:
- NotificationTypeItem (untuk checkbox item notifikasi)
```

### AboutAppScreen

```dart
Static content dengan:
- Logo display
- App info (version, description)
- Features list (4 items dengan icons)
- Developer info
- Legal notice
- Links (Privacy & ToS)

Method:
- _buildFeatureItem() → Build feature card
- _buildInfoRow() → Build info row
```

### HelpFaqScreen

```dart
- selectedCategory: String
- filteredFAQ: List<FAQItem>
- faqItems: List<FAQItem> (10 items predefined)

Methods:
- _filterByCategory() → Filter FAQ items
- initState() → Load FAQ dan default filter

Widgets:
- FAQItemWidget (expandable tile untuk setiap FAQ)

Features:
- Search functionality (client-side filtering)
- Category filtering
- Expandable FAQ items
```

### NotificationService

```dart
Static methods:
- initialize() → Set up periodic check
- _startPeriodicCheck() → Start Timer.periodic(15min)
- stopPeriodicCheck() → Cancel timer
- isNotificationEnabled() → Get status
- setNotificationEnabled(bool) → Set & update timer
- _saveLastCheckTime() → Save ke SharedPreferences
- _loadLastCheckTime() → Load dari SharedPreferences
- getNewArticleCount() → Count artikel baru
- checkForNewArticles() → Main check function
- getLatestArticles() → Fetch dari API & sort

Properties:
- _periodicTimer: Timer?
- _lastCheckTime: DateTime?

API Calls:
- GET /api/artikel (untuk cek artikel baru)
- Headers: Authorization Bearer token
```

## 🔌 Integration Points

### dengan EditProfileScreen

- Profile photo upload → display di ProfileScreen
- Username/full name update → display di ProfileScreen

### dengan API Client (api.dart)

- Menggunakan `Api.defaultHeaders()` untuk auth token
- GET request ke `/api/artikel`

### dengan SharedPreferences

- Store/retrieve user preferences
- Store notification check timestamp

### dengan Navigation

- Navigator.push() untuk membuka halaman baru
- MaterialPageRoute untuk transition

## 📱 UI Consistency

Semua screen menggunakan:

**Header Pattern:**

```dart
Padding with back button (InkWell with Container)
  + Screen title (Text 28px bold)
  + LogoAsset (top right untuk beberapa screen)
```

**Content Pattern:**

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [BoxShadow(...)]
  ),
  child: ListView(...)
)
```

**Colors:**

- Primary: hepCareBlue (#1E88E5)
- Background: primaryLightBlue (#E3F2FD)
- Accent: hepCareGreen (#4CAF50)
- Text: Colors.black87, Colors.black54, Colors.black38

**Spacing:**

- Standard padding: 16, 20, 24px
- Gap between sections: 12, 20, 24px
- Border radius: 12, 15, 20px

## 🚀 Fitur Bonus

### Search di Help & FAQ

```dart
onChanged: (value) {
  if (value.isEmpty) {
    _filterByCategory(selectedCategory);
  } else {
    filteredFAQ = faqItems
      .where((item) =>
        item.question.toLowerCase().contains(value.toLowerCase()) ||
        item.answer.toLowerCase().contains(value.toLowerCase())
      )
      .toList();
  }
}
```

### Periodic Notification Check

```dart
void _startPeriodicCheck() {
  _periodicTimer?.cancel();
  _periodicTimer = Timer.periodic(
    const Duration(minutes: 15),
    (_) => checkForNewArticles()
  );
}
```

### Article Date Comparison

```dart
// Parse artikel date dan compare dengan last check
final articleDate = DateTime.parse(createdAt);
if (articleDate.isAfter(_lastCheckTime!)) {
  newCount++;
}
```

---

**Status:** ✅ Semua komponen siap digunakan
**Testing:** Silakan test setiap menu dan fitur notifikasi
**Future:** Integrasikan FCM untuk push notification real-time
