# 📱 Visual User Flow & Feature Overview

## 🎬 Complete User Journey

```
┌─────────────────────────────────────────────────────────────┐
│                    MAIN APPLICATION                         │
│                                                             │
│                      Landing Page                          │
│                   [Greet User + Menu]                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
        ┌────────────────────────────────────┐
        │    Profile Page - 6 Menu Items      │
        ├────────────────────────────────────┤
        │  [1] Edit Profile                  │
        │  [2] Setting ⭐ NEW                │
        │  [3] Notification Preferences ⭐   │
        │  [4] Tentang Aplikasi ⭐ NEW       │
        │  [5] Bantuan & FAQ ⭐ NEW          │
        │  [6] Log Out                       │
        └────────────────────────────────────┘
         │    │         │          │          │
         │    │         │          │          └──→ Log Out → Login
         │    │         │          │
         │    │         │          └──→ About App Screen (info)
         │    │         │
         │    │         └──→ Help & FAQ Screen
         │    │              - Search bar
         │    │              - Category filter
         │    │              - 10 FAQ items
         │    │              - Support contact
         │    │
         │    └──→ Settings Screen
         │         - Dark Mode toggle
         │         - Sound toggle
         │         - Vibration toggle
         │         - Notification toggle
         │         - Clear cache button
         │
         └──→ Notification Preferences Screen
              - Main toggle (enable/disable)
              - New articles counter
              - 3 notification types
              - Support contact
              - Tips info box

```

## 🔔 Notification System Flow

```
                 User Enabled Notifications
                          ↓
              ┌───────────────────────────┐
              │  NotificationService      │
              │  .setNotificationEnabled  │
              │     (true)                │
              └────────────┬──────────────┘
                           ↓
              ┌───────────────────────────┐
              │  Save to SharedPrefs:     │
              │  notifications_enabled=1 │
              └────────────┬──────────────┘
                           ↓
              ┌───────────────────────────┐
              │  Start Timer.periodic     │
              │  (15 minutes interval)    │
              └────────────┬──────────────┘
                           ↓
              ┌───────────────────────────┐
              │  Every 15 minutes:        │
              │  checkForNewArticles()    │
              └────────────┬──────────────┘
                           ↓
              ┌───────────────────────────┐
              │  GET /api/artikel         │
              │  (with auth token)        │
              └────────────┬──────────────┘
                           ↓
              ┌───────────────────────────┐
              │  Parse JSON & Compare:    │
              │  article.date >           │
              │  last_article_check       │
              └────────────┬──────────────┘
                           ↓
              ┌─────────────────────────────────┐
              │  New Articles Found?            │
              ├─────────────────────────────────┤
              │ YES → newCount++                │
              │       Update last_check_time    │
              │       Debug: "📢 Ada N baru..." │
              │       (Future: FCM/Local notif) │
              │                                 │
              │ NO  → Continue waiting          │
              └─────────────────────────────────┘
```

## 📊 Screen Hierarchy

```
Application Root
│
├── Home/Landing Page
│   ├── Quiz Menu
│   ├── History Menu
│   ├── Maps Menu
│   ├── Articles Menu
│   └── Profile Icon [→ Profile Page]
│
├── Profile Page ⭐ Central Hub
│   ├── Profile Photo
│   ├── Username
│   ├── Menu List:
│   │   ├── Edit Profile [→ EditProfileScreen]
│   │   ├── Settings [→ SettingsScreen] ⭐ NEW
│   │   ├── Notifications [→ NotificationPreferencesScreen] ⭐ NEW
│   │   ├── About [→ AboutAppScreen] ⭐ NEW
│   │   ├── Help [→ HelpFaqScreen] ⭐ NEW
│   │   └── Log Out [→ LoginScreen]
│
├── Settings Screen (NEW)
│   ├── Appearance Section
│   │   └── Dark Mode Toggle
│   ├── Notification Section
│   │   ├── Notification Toggle
│   │   ├── Sound Toggle
│   │   └── Vibration Toggle
│   └── Info Section
│       └── Clear Cache Action
│
├── Notification Preferences Screen (NEW)
│   ├── Loading State
│   ├── Main Toggle
│   ├── Article Counter
│   ├── Notification Types
│   │   ├── Article Notifications
│   │   ├── Reminder Notifications
│   │   └── Urgent Notifications
│   ├── Info Box
│   └── Support Contact
│
├── About App Screen (NEW)
│   ├── Logo & Version
│   ├── Description
│   ├── Features List (4 items)
│   ├── Developer Info
│   ├── Legal Notice
│   └── Links (Privacy, ToS)
│
└── Help & FAQ Screen (NEW)
    ├── Search Bar
    ├── Category Filter
    ├── FAQ Items (10)
    │   ├── Kuis Kesehatan (2)
    │   ├── Riwayat (1)
    │   ├── Profil (1)
    │   ├── Notifikasi (1)
    │   ├── Pemetaan (1)
    │   ├── Keamanan (1)
    │   ├── Support (1)
    │   └── Akun (2)
    └── Support Contact
```

## 🎨 Screen Design Reference

### Settings Screen Layout

```
┌──────────────────────────────────┐
│ ← Settings                    🏥 │  ← Header
├──────────────────────────────────┤
│                                  │
│   TAMPILAN                       │
│  [🌙 Mode Gelap              [o]│  ← Toggle Off
│   Ubah tema aplikasi        │
│   ────────────────────────────   │
│                                  │
│   NOTIFIKASI                     │
│  [🔔 Notifikasi Umum        [o] ]│  ← Toggle Off
│   Terima notifikasi aplikasi     │
│   ────────────────────────────   │
│  [🔊 Suara                   [•] ]│  ← Toggle On
│   Aktifkan suara notifikasi      │
│   ────────────────────────────   │
│  [📳 Getaran                 [•] ]│  ← Toggle On
│   Aktifkan getaran notifikasi    │
│   ────────────────────────────   │
│                                  │
│   INFORMASI                      │
│  [🗑️ Hapus Cache Data            │  ← Action Item
│   Bersihkan penyimpanan sementara│
│   ────────────────────────────   │
│                                  │
└──────────────────────────────────┘
```

### Notification Preferences Screen Layout

```
┌──────────────────────────────────────┐
│ ← Preferensi Notifikasi          🏥 │  ← Header
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 🔔 Aktifkan Notifikasi   [•] │  │  ← Main Toggle
│  │ Terima notifikasi tentang...  │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 📰 Artikel Terbaru              │  │
│  │ Ada 3 artikel baru untuk dibaca │  │ ← Counter
│  └────────────────────────────────┘  │
│                                      │
│  TIPE NOTIFIKASI                     │
│  ┌────────────────────────────────┐  │
│  │ 📰 Artikel Terbaru      [•]   │  │  ← Type 1
│  │ Notifikasi artikel kesehatan   │  │
│  │ ────────────────────────────── │  │
│  │ ⏰ Pengingat Pemeriksaan [•]   │  │  ← Type 2
│  │ Pengingat pemeriksaan rutin    │  │
│  │ ────────────────────────────── │  │
│  │ ⚠️ Notifikasi Penting   [•]   │  │  ← Type 3
│  │ Pemberitahuan penting          │  │
│  └────────────────────────────────┘  │
│                                      │
│  ℹ️ TIPS                             │
│  Aktifkan notifikasi untuk mendapat  │
│  update artikel terbaru...           │
│                                      │
│  📧 HUBUNGI DUKUNGAN                │
│  Email: support@hepcare.com         │
│  Telepon: +62-800-1234-5678         │
│                                      │
└──────────────────────────────────────┘
```

### Help & FAQ Screen Layout

```
┌──────────────────────────────────┐
│ ← Bantuan & FAQ              🏥 │  ← Header
├──────────────────────────────────┤
│  [🔍 Cari pertanyaan...         │  ← Search
│                                  │
│  [Semua] [Kuis] [Riwayat] [...]  │  ← Filter Chips
│                                  │
│  ┌──────────────────────────────┐│
│  │ ▼ Bagaimana cara mengisi kuis?│  ← FAQ Item (Expandable)
│  │   Kuis Kesehatan              │
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │ ▶ Apa arti tingkat risiko?    │  ← FAQ Item (Collapsed)
│  │   Kuis Kesehatan              │
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │ ▶ Bagaimana cara...           │  ← FAQ Item (Collapsed)
│  │   Riwayat Pemeriksaan         │
│  └──────────────────────────────┘│
│                                  │
│  ... (more FAQ items) ...         │
│                                  │
│  📧 HUBUNGI DUKUNGAN              │
│  Email: support@hepcare.com      │
│  Telepon: +62-800-1234-5678      │
│                                  │
└──────────────────────────────────┘
```

### About App Screen Layout

```
┌──────────────────────────────────┐
│ ← Tentang Aplikasi           🏥 │  ← Header
├──────────────────────────────────┤
│                                  │
│          ┌─────────────┐         │
│          │  [Logo]     │         │
│          │ HepCare 🏥  │         │  ← Logo Section
│          └─────────────┘         │
│          v1.0.0                  │
│                                  │
│  TENTANG HEPCARE                 │
│  HepCare adalah aplikasi         │  ← Description
│  kesehatan yang dirancang...     │
│                                  │
│  FITUR UTAMA                     │
│  📝 Kuis Kesehatan              │
│     Ikuti kuis interaktif...     │  ← Features
│  📊 Riwayat Pemeriksaan         │
│     Pantau riwayat...            │
│  📍 Peta Rumah Sakit             │
│  📰 Artikel Kesehatan            │
│                                  │
│  INFORMASI PENGEMBANG            │
│  Versi:        1.0.0             │  ← Dev Info
│  Platform:     Flutter           │
│  Sistem:       Android & iOS     │
│  Lisensi:      Proprietary       │
│                                  │
│  ⚖️ PEMBERITAHUAN HUKUM          │
│  Aplikasi ini hanya untuk...     │
│                                  │
│  🔗 [Privasi] • [Syarat]        │  ← Links
│                                  │
└──────────────────────────────────┘
```

## 🔄 Data Persistence Flow

```
User Action
    ↓
UI Component Updates (setState)
    ↓
SharedPreferences.setBool/setString
    ↓
Data Saved Locally
    ↓
┌──────────────────────────────┐
│  App Restart/Reopen          │
└──────────────────────────────┘
    ↓
initState() calls _loadPreferences()
    ↓
SharedPreferences.getBool/getString
    ↓
Data Retrieved & Displayed
    ↓
UI Shows Saved State ✓
```

## 📱 Response Flow

```
NotificationPreferencesScreen
    ↓
User toggles "Aktifkan Notifikasi"
    ↓
setState(() => _notificationsEnabled = value)
    ↓
NotificationService.setNotificationEnabled(value)
    ↓
SharedPreferences.setBool('notifications_enabled', value)
    ↓
├─ If TRUE: _startPeriodicCheck() → Timer.periodic start
├─ If FALSE: stopPeriodicCheck() → Timer.cancel()
│
└─ showSnackBar("Notifikasi diaktifkan/nonaktifkan")
    ↓
SnackBar Dismisses
    ↓
User sees updated preference next time open screen ✓
```

## 🎯 Feature Completeness Matrix

```
Feature              |  Status  |  Location
─────────────────────┼──────────┼─────────────────────
Settings             |  ✅ DONE |  lib/settings.dart
├─ Dark Mode         |  ✅ DONE |  settings.dart line 62
├─ Sound             |  ✅ DONE |  settings.dart line 68
├─ Vibration         |  ✅ DONE |  settings.dart line 74
├─ Notification      |  ✅ DONE |  settings.dart line 80
└─ Clear Cache       |  ✅ DONE |  settings.dart line 86

Notifications        |  ✅ DONE |  lib/notification_preferences.dart
├─ Main Toggle       |  ✅ DONE |  line 75
├─ Article Counter   |  ✅ DONE |  line 85
├─ Type Toggles      |  ✅ DONE |  line 120-145
└─ Support Info      |  ✅ DONE |  line 180

About App           |  ✅ DONE |  lib/about_app.dart
├─ Logo Display      |  ✅ DONE |  line 60
├─ Features          |  ✅ DONE |  line 90
├─ Dev Info          |  ✅ DONE |  line 140
└─ Legal Notice      |  ✅ DONE |  line 175

Help & FAQ          |  ✅ DONE |  lib/help_faq.dart
├─ Search            |  ✅ DONE |  line 80
├─ Category Filter   |  ✅ DONE |  line 105
├─ 10 FAQ Items      |  ✅ DONE |  line 12-110
└─ Support Contact   |  ✅ DONE |  line 200

Notification Svc    |  ✅ DONE |  lib/notification_service.dart
├─ Timer Init        |  ✅ DONE |  line 25
├─ Periodic Check    |  ✅ DONE |  line 35
├─ API Integration   |  ✅ DONE |  line 55
└─ Persistence       |  ✅ DONE |  line 70

Profile Integration |  ✅ DONE |  lib/profile.dart
├─ Imports           |  ✅ DONE |  line 10-13
└─ Navigation        |  ✅ DONE |  line 320-370
```

---

**Visual Guide Complete! All features are ready for production.** 🎉
