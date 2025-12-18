import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// =========================================================================
// DEFINISI KONSTANTA
// =========================================================================

const Color _primaryColor = Color(0xFF0D98A7);
const Color _backgroundColor = Color(0xFFF7F9FC);

// URL Dasar API (Pastikan IP ini benar untuk Emulator)
const String _baseUrlApi = 'http://192.168.0.103:8000/api';

// =========================================================================
// BAGIAN 1: MODEL DATA ARTIKEL
// =========================================================================

class Article {
  final int id;
  final String judul;
  final String deskripsi;
  final String pencipta;
  final String tanggalBuat;
  final String? gambar;
  final String? jenis;

  // GETTER BARU DENGAN PERBAIKAN URL (Tidak ada /api/ ganda)
  String get imageUrl =>
      gambar != null ? '$_baseUrlApi/artikel/gambar/$gambar' : '';

  Article({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.pencipta,
    required this.tanggalBuat,
    this.gambar,
    this.jenis,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      pencipta: json['pencipta'],
      tanggalBuat: json['tanggal_buat'] != null
          ? json['tanggal_buat'].toString().substring(0, 10)
          : 'Tanggal Tidak Diketahui',
      gambar: json['gambar'],
      jenis: json['jenis'],
    );
  }
}

// =========================================================================
// BAGIAN 2: HALAMAN DETAIL ARTIKEL (ArticleDetailScreen)
// =========================================================================

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // DEBUG: Cek URL yang dicoba dimuat
    debugPrint('Mencoba memuat URL: ${article.imageUrl}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.judul,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilan Gambar (Jika ada)
              if (article.gambar != null && article.gambar!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,

                    // FIX UTAMA: Menambahkan header untuk mengatasi masalah koneksi/caching HTTP lokal
                    headers: const {
                      'connection': 'close',
                      'cache-control': 'no-cache',
                    },

                    errorBuilder: (context, error, stackTrace) {
                      // DEBUG: Cetak error jika gambar gagal dimuat
                      debugPrint('GAGAL MEMUAT GAMBAR: $error');
                      return const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // Judul Artikel
              Text(
                article.judul,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Tampilkan Jenis Artikel
              if (article.jenis != null && article.jenis!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    article.jenis!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),

              // Meta Info
              const SizedBox(height: 8),
              Text(
                'Oleh: ${article.pencipta} | Tanggal: ${article.tanggalBuat}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const Divider(height: 25),

              // Deskripsi/Isi Artikel
              Text(
                article.deskripsi,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),

              const SizedBox(height: 40),

              // Tombol Kembali
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kembali ke Daftar Artikel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// BAGIAN 3: KOMPONEN CARD KECIL (ArticleCardSmall)
// =========================================================================

class ArticleCardSmall extends StatelessWidget {
  final Article article;
  final VoidCallback onTapSelengkapnya;

  const ArticleCardSmall({
    super.key,
    required this.article,
    required this.onTapSelengkapnya,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.judul,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            article.deskripsi,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 35,
              child: ElevatedButton(
                onPressed: onTapSelengkapnya,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selengkapnya',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// BAGIAN 4: KONTEN BODY HALAMAN ARTIKEL (ArticleScreenBody)
// =========================================================================

class ArticleScreenBody extends StatelessWidget {
  final List<Article> hepatitisArticles;
  final List<Article> healthArticles;

  const ArticleScreenBody({
    super.key,
    required this.hepatitisArticles,
    required this.healthArticles,
  });

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  Widget _buildHorizontalArticleList({
    required BuildContext context,
    required List<Article> articles,
  }) {
    if (articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          'Tidak ada artikel di kategori ini.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: articles.map((article) {
          return ArticleCardSmall(
            article: article,
            onTapSelengkapnya: () => _navigateToDetail(context, article),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainBanner(BuildContext context) {
    const String bannerPath = 'assets/artikelfoto.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
              image: AssetImage(bannerPath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Lindungi Kesehatan\nAnda dan Keluarga',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainBanner(context),

          if (hepatitisArticles.isNotEmpty) ...[
            _buildSectionTitle('Hepatitis'),
            _buildHorizontalArticleList(
              context: context,
              articles: hepatitisArticles,
            ),
            const SizedBox(height: 20),
          ],

          if (healthArticles.isNotEmpty) ...[
            _buildSectionTitle('Kesehatan Umum'),
            _buildHorizontalArticleList(
              context: context,
              articles: healthArticles,
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// =========================================================================
// BAGIAN 5: WIDGET HALAMAN UTAMA (ArticleScreen)
// =========================================================================

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> futureHepatitisArticles;
  late Future<List<Article>> futureHealthArticles;

  final String _baseUrl = '$_baseUrlApi/artikel';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    futureHepatitisArticles = fetchArticlesByJenis('Hepatitis');
    futureHealthArticles = fetchArticlesByJenis('Kesehatan');
  }

  Future<List<Article>> fetchArticlesByJenis(String jenis) async {
    final url = Uri.parse('$_baseUrl?role=$jenis');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.isEmpty ||
            body == '[]' ||
            body.toLowerCase() == 'null' ||
            body.contains("Tidak ada artikel")) {
          return [];
        }

        List jsonResponse = json.decode(body);
        return jsonResponse.map((item) => Article.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
          'Gagal memuat artikel jenis $jenis: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error koneksi atau parsing untuk jenis $jenis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: null,
        automaticallyImplyLeading: true,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Image.asset('assets/logo.png', height: 90),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.black.withOpacity(0.7),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<List<Article>>>(
        future: Future.wait([futureHepatitisArticles, futureHealthArticles]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Gagal memuat artikel.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pastikan server Flask berjalan. Error: ${snapshot.error.toString()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadArticles();
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            final List<Article> hepatitisArticles = snapshot.data![0];
            final List<Article> healthArticles = snapshot.data![1];

            return ArticleScreenBody(
              hepatitisArticles: hepatitisArticles,
              healthArticles: healthArticles,
            );
          }

          return const Center(child: Text('Memuat data...'));
        },
      ),
    );
  }
}
