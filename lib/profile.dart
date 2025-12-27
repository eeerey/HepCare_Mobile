import 'package:flutter/material.dart';
// 💡 Import library untuk menyimpan data lokal (token)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart'; // Import centralized API client
// Ganti dengan import yang benar ke EditProfileScreen Anda
import '../editprofile.dart';
// 💡 Ganti dengan import ke halaman login/welcome Anda
import '../login.dart'; // Contoh import ke halaman setelah logout
import 'settings.dart';
import 'notification_preferences.dart';
import 'about_app.dart';
import 'help_faq.dart';

// Definisi Warna Kustom
const Color primaryLightBlue = Color(0xFFE3F2FD);
const Color hepCareBlue = Color(0xFF1E88E5);
const Color hepCareGreen = Color(0xFF4CAF50);

// 💡 UBAH DARI StatelessWidget MENJADI StatefulWidget
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _photoUrl;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    // Coba beberapa key token yang mungkin digunakan
    final String? authToken =
        prefs.getString('jwt_token') ?? prefs.getString('access_token');
    if (authToken == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final url = Uri.parse('${Api.baseUrl}/api/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('Profile API Status: ${response.statusCode}');
      debugPrint('Profile API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Photo URL: ${data['photoUrl']}');
        setState(() {
          _username = data['fullName'] ?? data['username'] ?? '';
          _photoUrl = data['photoUrl'];
          _isLoading = false;
        });
      } else {
        debugPrint('Profile fetch failed: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 💡 FUNGSI LOG OUT SESUNGGUHNYA
  Future<void> _handleLogout() async {
    // 1. Tampilkan Dialog Konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Batal
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Konfirmasi Logout
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // Jika pengguna mengkonfirmasi logout
    if (confirmed == true) {
      try {
        // 2. Hapus Token/Data Lokal
        final prefs = await SharedPreferences.getInstance();
        // Hapus token JWT yang Anda gunakan untuk otentikasi
        await prefs.remove('access_token');
        // Hapus ID pengguna atau data profil yang tersimpan secara lokal
        await prefs.remove('user_id');

        // 3. Navigasi ke Halaman Login dan hapus semua rute sebelumnya
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  const HepCareLoginPage(), // 💡 Ganti dengan Screen Login/Welcome Anda
            ),
            (Route<dynamic> route) => false, // Hapus semua stack navigasi
          );
        }
      } catch (e) {
        debugPrint('Error saat melakukan logout: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal melakukan logout. Coba lagi.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: primaryLightBlue),
        child: Column(
          children: [
            // --- BAGIAN HEADER ---
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.07,
                left: 16.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                  ),
                  Row(children: [Image.asset('assets/logo.png', height: 30)]),
                ],
              ),
            ),

            // --- JUDUL DAN FOTO PROFIL ---
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 20.0),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _isLoading
                        ? Center()
                        : (_photoUrl != null && _photoUrl!.isNotEmpty)
                        ? Image.network(
                            _photoUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/profile_pic.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 30.0),
              child: Text(
                _isLoading
                    ? 'Memuat...'
                    : (_username.isNotEmpty ? _username : 'Pengguna'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // --- DAFTAR MENU (LISTVIEW) ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    // ITEM EDIT PROFILE dengan NAVIGASI
                    ProfileMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Setting',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItem(
                      icon: Icons.notifications_none,
                      title: 'Notification Preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationPreferencesScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title:
                          'Tentang Aplikasi', // Mengganti teks agar lebih bervariasi
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutAppScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItem(
                      icon: Icons.menu_book_outlined,
                      title:
                          'Bantuan & FAQ', // Mengganti teks agar lebih bervariasi
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpFaqScreen(),
                          ),
                        );
                      },
                    ),

                    // Item Log Out
                    ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'Log Out',
                      isLogout: true,
                      onTap: _handleLogout, // 💡 Panggil fungsi Log Out
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// DEFINISI WAJIB: PROFILE MENU ITEM
// ==========================================================

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Ganti warna menjadi merah untuk Log Out
    final Color iconColor = isLogout ? Colors.red : Colors.black54;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25.0,
            vertical: 4.0,
          ),
          leading: Icon(icon, color: iconColor, size: 28),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              // 💡 Ganti warna teks menjadi merah untuk Log Out
              color: isLogout ? Colors.red : Colors.black87,
              fontWeight: isLogout ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: isLogout
              ? null
              : const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black26,
                  size: 18,
                ),
          onTap: onTap,
        ),
        // Garis Pembatas (tidak perlu di Log Out)
        if (!isLogout)
          const Divider(
            height: 1,
            color: Color(0xFFE0E0E0),
            indent: 70,
            endIndent: 20,
          ),
      ],
    );
  }
}
