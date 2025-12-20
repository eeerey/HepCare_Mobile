import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'dart:convert'; // DITAMBAHKAN: Untuk konversi data JSON
import 'package:http/http.dart'
    as http; // DITAMBAHKAN: Untuk melakukan HTTP POST

// =======================================================================
// ALAMAT API KRITIS (HARAP SESUAIKAN DENGAN SETUP SERVER FLASK ANDA)
// =======================================================================
// Gunakan:
// - 'http://10.0.2.2:5000/api'  (Jika menggunakan Android Emulator)
// - 'http://127.0.0.1:5000/api' (Jika menggunakan iOS Simulator atau web)
// - 'http://[IP_LOKAL_PC_ANDA]:5000/api' (Jika menggunakan device fisik/ponsel)
const String API_BASE_URL = 'http://192.168.0.102:8081/api';
// =======================================================================

// =======================================================================
// CLASS UTAMA: RegistrationPage
// =======================================================================

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // START: TEXT EDITING CONTROLLERS
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmPasswordController =
      TextEditingController();
  // END: TEXT EDITING CONTROLLERS

  bool _isLoading = false; // Status untuk tombol loading
  final Color buttonGold = const Color(0xFFFFCC33);
  final Color tealColor = const Color(0xFF38A169);

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _tglLahirController.dispose();
    _passwordController.dispose();
    _konfirmPasswordController.dispose();
    super.dispose();
  }

  // FUNGSI DATE PICKER
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Format tanggal menjadi YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _tglLahirController.text = formattedDate;
      });
    }
  }

  // ==============================================================
  // FUNGSI REGISTRASI BARU (Mengganti Simulasi)
  // ==============================================================
  Future<void> _performRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop jika validasi gagal
    }

    // Validasi Konfirmasi Password
    if (_passwordController.text != _konfirmPasswordController.text) {
      _showErrorSnackBar('Password dan Konfirmasi Password tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/register'),
        headers: <String, String>{
          // KRITIS: Memberi tahu Flask bahwa kita mengirim JSON
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          // KRITIS: Kunci HARUS SAMA dengan yang dicari di AuthController.py
          'nama': _namaController.text,
          'email': _emailController.text,
          'username': _usernameController.text,
          'tanggal_lahir': _tglLahirController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // Status 201 Created (Registrasi Sukses dari Flask)
        _showSuccessDialog("Registrasi Berhasil!", "Selamat datang!");
      } else if (response.statusCode == 400) {
        // Status 400 Bad Request (Misalnya: Username sudah terdaftar)
        final body = jsonDecode(response.body);
        _showErrorSnackBar(body['error'] ?? "Gagal: Cek input Anda.");
      } else {
        // Status error lainnya (termasuk 404 Not Found)
        print('Status Code: ${response.statusCode}');
        _showErrorSnackBar(
          "Gagal: Terjadi kesalahan server (${response.statusCode})",
        );
      }
    } catch (e) {
      // Error Jaringan (Connection refused, DNS lookup failed, timeout)
      print('Error Jaringan: $e');
      _showErrorSnackBar(
        "Gagal terhubung ke server. Cek alamat IP atau koneksi Anda.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper function untuk menampilkan SnackBar Error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper function untuk menampilkan Dialog Sukses
  void _showSuccessDialog(String title, String subtitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check_circle, color: tealColor, size: 80.0),
              const SizedBox(height: 20.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ), // Pindah ke Home
                );
              },
              child: Text("OK", style: TextStyle(color: tealColor)),
            ),
          ],
        );
      },
    );
  }
  // ==============================================================
  // END FUNGSI REGISTRASI BARU
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFB3E0FF),
                  Color(0xFFD9E9F0),
                  Color(0xFFE0E0E0),
                ],
              ),
            ),
          ),

          // 2. Konten Halaman Registrasi
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.1),

                  const HepCareLogo(), // Safe now, defined below

                  const SizedBox(height: 50),

                  // Form Input Fields
                  _buildInputField(
                    hintText: 'Nama',
                    isValidator: true,
                    controller: _namaController,
                  ),
                  _buildInputField(
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    isValidator: true,
                    controller: _emailController,
                  ),
                  _buildInputField(
                    hintText: 'Username',
                    isValidator: true,
                    controller: _usernameController,
                  ),

                  // INPUT TANGGAL LAHIR DENGAN DATE PICKER
                  _buildInputField(
                    hintText: 'Tanggal Lahir (YYYY-MM-DD)',
                    icon: Icons.calendar_today,
                    controller: _tglLahirController,
                    isValidator: true,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),

                  _buildInputField(
                    hintText: 'Password',
                    isPassword: true,
                    isValidator: true,
                    controller: _passwordController,
                  ),
                  _buildInputField(
                    hintText: 'Konfirmasi Password',
                    isPassword: true,
                    isValidator: true,
                    controller: _konfirmPasswordController,
                  ),

                  // Tombol Register
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      // Panggil fungsi performRegistration yang sudah diperbaiki
                      onPressed: _isLoading ? null : _performRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.3),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('REGISTER'),
                    ),
                  ),

                  // Bagian Social Login
                  const SizedBox(height: 20),
                  const Text(
                    'Atau Login dengan',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 15),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLoginButton(
                        assetPath: 'assets/google.png',
                        iconColor: Color(0xFF4285F4),
                      ),
                      SizedBox(width: 20),
                      SocialLoginButton(
                        assetPath: 'assets/facebook.png',
                        iconColor: Color(0xFF1877F2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // 3. Tombol Kembali
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Pembantu (Helper Widgets) ---

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    bool isValidator = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: isValidator
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$hintText tidak boleh kosong';
                }
                if (hintText.contains('Password') && value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF888888), size: 20)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: tealColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// WIDGET PEMBANTU (Disertakan agar kode dapat dikompilasi)
// =======================================================================

// Widget untuk Logo HepCare
class HepCareLogo extends StatelessWidget {
  const HepCareLogo({super.key});

  @override
  Widget build(BuildContext context) {
    const double logoHeight = 80;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Menggunakan Icon placeholder jika assets/logo.png tidak ditemukan
        Image.asset(
          'assets/logo.png',
          height: logoHeight,
          errorBuilder: (context, error, stackTrace) => Container(
            width: logoHeight,
            height: logoHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: const Color(0xFF38A169), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.vaccines, color: Color(0xFF38A169), size: 30),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

// Widget untuk Tombol Social Login
class SocialLoginButton extends StatelessWidget {
  final String assetPath;
  final Color iconColor;

  const SocialLoginButton({
    super.key,
    required this.assetPath,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Simulasi Login dengan Social Media');
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          // Menggunakan ikon placeholder
          child: Icon(
            assetPath.contains('google') ? Icons.g_mobiledata : Icons.facebook,
            color: iconColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}
