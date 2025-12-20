import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// =========================================================================
// KONFIGURASI API DAN MODEL
// =========================================================================

// Ganti dengan IP Address lokal komputer Anda dan port Flask (biasanya 5000)
// Contoh: 'http://192.168.1.100:5000/rumahsakit'
const String FLASK_API_BASE_URL = 'http://192.168.0.102:8081/rumahsakit';
// Catatan: 10.0.2.2 adalah alias untuk localhost di emulator Android.
// Jika menggunakan perangkat fisik, GANTI dengan IP komputer Anda.

// --- Model Data Rumah Sakit (Disesuaikan dengan field DB Flask Anda) ---
class Hospital {
  final int id;
  final String name;
  final String address;
  final String? noTelp;
  final String? deskripsi;
  final String? imageUrl;
  final String type; // Dipertahankan untuk tampilan UI 'Umum'

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    this.noTelp,
    this.deskripsi,
    this.imageUrl,
    this.type = 'Umum',
  });

  // Factory constructor untuk mapping data JSON dari Flask
  factory Hospital.fromJson(Map<String, dynamic> json) {
    // URL untuk mengambil gambar dari endpoint Flask: /rumahsakit/gambar/<filename>
    String? fullImageUrl;
    if (json['gambar'] != null) {
      fullImageUrl = '$FLASK_API_BASE_URL/gambar/${json['gambar']}';
    }

    return Hospital(
      id: json['id'] as int,
      name: json['nama'] as String, // Sesuai nama kolom DB: 'nama'
      address: json['alamat'] as String, // Sesuai nama kolom DB: 'alamat'
      noTelp: json['no_telp'] as String?,
      deskripsi: json['deskripsi'] as String?,
      imageUrl: fullImageUrl,
      type: 'Umum', // Default statis
    );
  }
}

// --- Fungsi Pengambilan Data dari Flask API ---
Future<List<Hospital>> fetchHospitals() async {
  try {
    final response = await http.get(Uri.parse(FLASK_API_BASE_URL));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Hospital.fromJson(json)).toList();
    } else {
      throw Exception(
        'Gagal memuat data dari server. Status: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error koneksi API: $e');
    throw Exception(
      'Gagal terhubung ke Flask API. Pastikan server berjalan di $FLASK_API_BASE_URL',
    );
  }
}

// =========================================================================
// MAIN APP
// =========================================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Rumah Sakit',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const HospitalListPage(),
    );
  }
}

// =========================================================================
// HALAMAN LIST RUMAH SAKIT
// =========================================================================

class HospitalListPage extends StatefulWidget {
  const HospitalListPage({super.key});

  @override
  State<HospitalListPage> createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  late Future<List<Hospital>> _hospitalsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Hospital> _allHospitals = [];
  List<Hospital> _filteredHospitals = [];

  void _filterHospitals(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHospitals = _allHospitals;
      } else {
        _filteredHospitals = _allHospitals.where((hospital) {
          return hospital.name.toLowerCase().contains(lowerCaseQuery) ||
              hospital.address.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  void _loadHospitals() {
    _hospitalsFuture = fetchHospitals().then((hospitals) {
      _allHospitals = hospitals;
      _filteredHospitals = hospitals;
      return hospitals;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHospitals();

    _searchController.addListener(() {
      _filterHospitals(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  // Widget Card Rumah Sakit
  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F1F8),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar (jika ada)
            if (hospital.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    hospital.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            // Nama Rumah Sakit
            Text(
              hospital.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 4),
            // Alamat
            Text(
              hospital.address,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            // Baris tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Tipe (Umum)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hospital.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Tombol Detail
                OutlinedButton(
                  onPressed: () {
                    // >>> LOGIKA NAVIGASI KE DETAIL PAGE <<<
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HospitalDetailPage(hospital: hospital),
                      ),
                    );
                    // >>> AKHIR LOGIKA NAVIGASI <<<
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF42A5F5),
                    side: const BorderSide(
                      color: Color(0xFF42A5F5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Menambahkan leading untuk tombol back manual jika diperlukan agar warna konsisten
        iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rumah Sakit',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Ganti Icon dengan Image.asset
              Image.asset(
                'assets/logo.png',
                height: 35, // Sesuaikan tinggi logo agar pas di AppBar
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF4CAF50),
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Widget Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Rumah sakit',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Daftar Rumah Sakit menggunakan FutureBuilder
          Expanded(
            child: FutureBuilder<List<Hospital>>(
              future: _hospitalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Gagal memuat data:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || _filteredHospitals.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data Rumah Sakit yang ditemukan.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: _filteredHospitals.length,
                    itemBuilder: (context, index) {
                      return _buildHospitalCard(_filteredHospitals[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// HALAMAN DETAIL RUMAH SAKIT
// =========================================================================

class HospitalDetailPage extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailPage({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          hospital.name,
          style: const TextStyle(color: Color(0xFF0D47A1)),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Detail (jika ada)
            if (hospital.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    hospital.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: Text("Gagal memuat gambar")),
                      );
                    },
                  ),
                ),
              ),

            // Nama Rumah Sakit
            Text(
              hospital.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),

            // Tipe RS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                hospital.type,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Divider(height: 30),

            // Detail Alamat
            _buildDetailRow(Icons.location_on, 'Alamat', hospital.address),
            const SizedBox(height: 10),

            // Detail Nomor Telepon
            if (hospital.noTelp != null && hospital.noTelp!.isNotEmpty)
              _buildDetailRow(Icons.phone, 'No. Telepon', hospital.noTelp!),
            const SizedBox(height: 20),

            // Deskripsi
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hospital.deskripsi ?? 'Tidak ada deskripsi tersedia.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Baris Detail
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF42A5F5), size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
