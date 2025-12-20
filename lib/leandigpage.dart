import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini

// Import file pendukung

import '../widgets/navbar.dart';

import 'artikel.dart';

import 'rumahsakit.dart';

import 'pemetaan.dart';

import 'kuisioner.dart';

class Leandigpage extends StatefulWidget {
  final String username;

  const Leandigpage({super.key, this.username = 'Pengguna'});

  @override
  State<Leandigpage> createState() => _LeandigpageState();
}

class _LeandigpageState extends State<Leandigpage> {
  int _selectedIndex = 0;

  static const Color primaryColor = Color(0xFF0D98A7);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 203, 236, 243),

      body: CustomScrollView(
        slivers: [
          // 1. Header (Logo & Profil)
          SliverToBoxAdapter(
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,

                  vertical: 10.0,
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Image.asset(
                      'assets/logo.png',

                      height: 80,

                      width: 100,

                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.health_and_safety,

                        color: primaryColor,

                        size: 40,
                      ),
                    ),

                    const CircleAvatar(
                      radius: 18,

                      backgroundColor: Colors.white,

                      child: Icon(
                        Icons.person_outline,

                        color: primaryColor,

                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Teks Sambutan
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Selamat Datang\nkembali,',

                          style: TextStyle(fontSize: 26, height: 1.1),
                        ),

                        Text(
                          '${widget.username}!',

                          style: const TextStyle(
                            fontSize: 30,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const CircleAvatar(
                    radius: 35,

                    backgroundColor: primaryColor,

                    child: Icon(Icons.person, color: Colors.white, size: 35),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 25)),

          // 3. Konten Utama
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),

                  topRight: Radius.circular(30),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildSectionTitle('Fitur aplikasi'),

                  const SizedBox(height: 16),

                  _buildFeatureRow(),

                  const SizedBox(height: 32),

                  _buildSectionTitle('Status Kuisioner'),

                  const SizedBox(height: 16),

                  QuizCard(
                    primaryColor: primaryColor,

                    username: widget.username,
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle('Artikel Terkini'),

                  const SizedBox(height: 16),

                  const ArticleCardDynamic(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        primaryColor: primaryColor,

        currentIndex: _selectedIndex,

        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 18,

        fontWeight: FontWeight.bold,

        color: Colors.black87,
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,

      children: [
        FeatureItem(
          icon: Icons.article_outlined,

          label: 'Artikel',

          onTap: () => _navigateToPage(const ArticleScreen()),
        ),

        FeatureItem(
          icon: Icons.local_hospital_outlined,

          label: 'Daftar RS',

          onTap: () => _navigateToPage(const HospitalListPage()),
        ),

        FeatureItem(
          icon: Icons.map_outlined,

          label: 'Pemetaan',

          onTap: () => _navigateToPage(const PemetaanPage()),
        ),
      ],
    );
  }
}

// ==========================================================

// QUIZCARD DINAMIS - DIPERBAIKI

// ==========================================================

class QuizCard extends StatefulWidget {
  final Color primaryColor;

  final String username;

  const QuizCard({
    super.key,

    required this.primaryColor,

    required this.username,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int? userId;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getInt(
        'user_id',
      ); // Pastikan key 'user_id' diset saat login

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.black12),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Test Sekarang',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const Text(
            'Ketahui tingkat risiko kesehatan Anda sejak dini.',

            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              ElevatedButton(
                // Di dalam class _QuizCardState di file leandigpage.dart
                onPressed: () {
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // INI BAGIAN KRUSIAL: Panggil StartScreen dengan userId
                        builder: (context) => StartScreen(userId: userId!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "ID User tidak ditemukan, silakan login kembali",
                        ),
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: const Text('Mulai Kuisioner'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================

// ARTIKEL CARD DINAMIS (Tetap Sama)

// ==========================================================

class ArticleCardDynamic extends StatefulWidget {
  const ArticleCardDynamic({super.key});

  @override
  State<ArticleCardDynamic> createState() => _ArticleCardDynamicState();
}

class _ArticleCardDynamicState extends State<ArticleCardDynamic> {
  Article? latestArticle;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.102:8081/api/artikel'),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            latestArticle = Article.fromJson(data[0]);

            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LinearProgressIndicator();

    if (latestArticle == null) return const Text("Artikel belum tersedia");

    return GestureDetector(
      onTap: () => Navigator.push(
        context,

        MaterialPageRoute(
          builder: (context) => ArticleDetailScreen(article: latestArticle!),
        ),
      ),

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: Colors.black12),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.network(
                latestArticle!.imageUrl,

                width: 80,

                height: 80,

                fit: BoxFit.cover,

                errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    latestArticle!.judul,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 16,
                    ),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    latestArticle!.deskripsi,

                    style: const TextStyle(color: Colors.black54, fontSize: 13),

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================

// FEATURE ITEM COMPONENT

// ==========================================================

class FeatureItem extends StatelessWidget {
  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const FeatureItem({
    super.key,

    required this.icon,

    required this.label,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Column(
        children: [
          Container(
            width: 65,

            height: 65,

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(15),

              border: Border.all(color: Colors.black12),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),

                  blurRadius: 5,

                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Icon(icon, color: const Color(0xFF0D98A7), size: 30),
          ),

          const SizedBox(height: 8),

          Text(
            label,

            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
