import 'package:flutter/material.dart';
import '../leandigpage.dart';
import '../profile.dart';
import '../history.dart'; // Pastikan path import ini benar

class BottomNavBar extends StatelessWidget {
  final Color primaryColor;
  final int currentIndex;
  final String username;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.primaryColor,
    required this.currentIndex,
    required this.onTap,
    this.username = 'Pengguna',
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 10,
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        // Logika Navigasi berdasarkan index
        if (index == 0) {
          if (currentIndex == 0) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Leandigpage(username: username),
            ),
          );
        } else if (index == 1) {
          // Navigasi ke Halaman History
          if (currentIndex == 1) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HistoryPage(username: username), // Kirim username
            ),
          );
        } else if (index == 2) {
          if (currentIndex == 2) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else {
          // Menjalankan fungsi asal untuk index lainnya (misal: Tagihan)
          onTap(index);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined), // Icon untuk History
          activeIcon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
