FCM Integration Guide (HepCare)

1. Firebase Project Setup

- Buka https://console.firebase.google.com/ dan buat project baru (atau gunakan existing).
- Tambahkan aplikasi Android (package name harus sama dengan `applicationId` di `android/app/build.gradle.kts`).
- Download `google-services.json` dan taruh di `android/app/`.
- Jika target iOS, tambahkan app iOS dan unduh `GoogleService-Info.plist` ke `ios/Runner`.

2. Android setup

- Tambahkan plugin di `android/build.gradle` dan `android/app/build.gradle` sesuai dokumentasi Firebase.
- Pastikan `minSdkVersion` >= 21.
- Tambahkan permission di `android/app/src/main/AndroidManifest.xml` jika diperlukan.
- Pastikan icon notifikasi (`@mipmap/ic_launcher`) ada.

3. Pubspec dependencies

- Sudah ditambahkan di `pubspec.yaml`:
  - `firebase_core`
  - `firebase_messaging`
  - `flutter_local_notifications`

4. Code

- `lib/fcm_service.dart` menyiapkan Firebase Messaging dan local notifications.
- `lib/main.dart` sudah diupdate untuk menginisialisasi Firebase dan `FcmService.initialize()`.

5. Backend (example)

- `web/backend/fcm_send_example.py` adalah contoh sederhana yang mengirim notifikasi ke topic `/topics/articles`.
- Ganti `SERVER_KEY` dengan Server Key project Firebase Anda.
- Di production, kirim pesan dari server saat admin menambahkan artikel.

6. Testing

- Jalankan app di device/emulator setelah menaruh `google-services.json`.
- Pastikan app meminta permission notifikasi (iOS).
- Tes kirim notifikasi dengan menjalankan `fcm_send_example.py` atau gunakan Firebase Console -> Cloud Messaging -> Send a test message -> Topic `articles`.

7. Notes

- Untuk notifikasi background delivery secara andal, gunakan FCM (push); polling tidak meng-cover app yang ditutup.
- Simpan device token di backend jika ingin mengirim target per-user (recommended).

8. Security

- Jangan simpan `SERVER_KEY` di client. Hanya di backend.

9. References

- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/cloud-messaging
- https://pub.dev/packages/firebase_messaging
- https://pub.dev/packages/flutter_local_notifications
