import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'api.dart'; // Import centralized API client

class NotificationService {
  static Timer? _periodicTimer;
  static DateTime? _lastCheckTime;

  /// Inisialisasi layanan notifikasi
  static Future<void> initialize() async {
    await _loadLastCheckTime();
    _startPeriodicCheck();
  }

  /// Mulai pengecekan artikel terbaru secara berkala (setiap 15 menit)
  static void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      checkForNewArticles();
    });
  }

  /// Hentikan pengecekan berkala
  static void stopPeriodicCheck() {
    _periodicTimer?.cancel();
  }

  /// Cek apakah notifikasi diaktifkan
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  /// Aktifkan/nonaktifkan notifikasi
  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      _startPeriodicCheck();
    } else {
      stopPeriodicCheck();
    }
  }

  /// Simpan waktu pengecekan terakhir
  static Future<void> _saveLastCheckTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_article_check', time.toIso8601String());
    _lastCheckTime = time;
  }

  /// Load waktu pengecekan terakhir
  static Future<void> _loadLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('last_article_check');
    if (lastCheck != null) {
      _lastCheckTime = DateTime.parse(lastCheck);
    }
  }

  /// Ambil jumlah artikel baru sejak pengecekan terakhir
  static Future<int> getNewArticleCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken =
          prefs.getString('jwt_token') ?? prefs.getString('access_token');

      if (authToken == null) return 0;

      final url = Uri.parse('${Api.baseUrl}/api/artikel');
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data is List
            ? data
            : (data['data'] ?? []);

        // Jika belum pernah cek, ambil semua artikel
        if (_lastCheckTime == null) {
          await _saveLastCheckTime(DateTime.now());
          return articles.length;
        }

        // Hitung artikel yang lebih baru dari pengecekan terakhir
        int newCount = 0;
        for (var article in articles) {
          final createdAt = article['created_at'] ?? article['date'];
          if (createdAt != null) {
            try {
              final articleDate = DateTime.parse(createdAt.toString());
              if (articleDate.isAfter(_lastCheckTime!)) {
                newCount++;
              }
            } catch (e) {
              continue;
            }
          }
        }

        return newCount;
      }
    } catch (e) {
      debugPrint('Error checking for new articles: $e');
    }
    return 0;
  }

  /// Cek artikel baru dan tampilkan notifikasi (untuk demo, menggunakan print)
  static Future<void> checkForNewArticles() async {
    final isEnabled = await isNotificationEnabled();
    if (!isEnabled) return;

    final newCount = await getNewArticleCount();
    if (newCount > 0) {
      await _saveLastCheckTime(DateTime.now());
      debugPrint('📢 NOTIFIKASI: Ada $newCount artikel terbaru untuk dibaca!');
      // Dalam aplikasi nyata, integrasikan dengan Firebase Cloud Messaging atau flutter_local_notifications
    }
  }

  /// Dapatkan daftar artikel terbaru (untuk ditampilkan di halaman notifikasi)
  static Future<List<dynamic>> getLatestArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken =
          prefs.getString('jwt_token') ?? prefs.getString('access_token');

      if (authToken == null) return [];

      final url = Uri.parse('${Api.baseUrl}/api/artikel');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> articles = data is List ? data : (data['data'] ?? []);

        // Urutkan dari terbaru ke terlama
        articles.sort((a, b) {
          final dateA = DateTime.tryParse(
            (a['created_at'] ?? a['date'] ?? '').toString(),
          );
          final dateB = DateTime.tryParse(
            (b['created_at'] ?? b['date'] ?? '').toString(),
          );
          return (dateB ?? DateTime(1970)).compareTo(dateA ?? DateTime(1970));
        });

        return articles;
      }
    } catch (e) {
      debugPrint('Error fetching latest articles: $e');
    }
    return [];
  }
}

// Dummy debugPrint untuk non-Flutter context
void debugPrint(String message) {
  print('[DEBUG] $message');
}
