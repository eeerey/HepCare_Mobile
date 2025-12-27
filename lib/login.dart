// main_login.dart (FIXED CODE)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'leandigpage.dart';

class HepCareLoginPage extends StatefulWidget {
  const HepCareLoginPage({super.key});

  @override
  State<HepCareLoginPage> createState() => _HepCareLoginPageState();
}

class _HepCareLoginPageState extends State<HepCareLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Color buttonYellow = const Color(0xFFFFC107);
  final Color buttonTeal = const Color(0xFF009688);
  final Color paleAzure = const Color(0xFFE1F5FE);

  // ======================================================
  // Dialog Status Login
  // ======================================================
  void _showStatusDialog(bool isSuccess, String message, {String? username}) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? buttonTeal : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (isSuccess) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Leandigpage(username: username ?? 'Pengguna'),
          ),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  // ======================================================
  // Proses Login ke Flask - PERBAIKAN DI SINI
  // ======================================================
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    final String currentUsername = _usernameController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    const String apiUrl = 'http://192.168.1.3:8081/api/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': currentUsername,
          'password': _passwordController.text,
        }),
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // 🔑 AMBIL TOKEN DAN USER_ID DARI BACKEND
        final String token = data['access_token'];
        final int userId =
            data['user_id']; // Pastikan Flask mengirimkan field ini

        // 🔑 SIMPAN KEDUANYA KE SHAREDPREFERENCES
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setInt(
          'user_id',
          userId,
        ); // Simpan ID agar kuesioner tidak error

        _showStatusDialog(true, "Login Berhasil!", username: currentUsername);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMessage =
            errorData['error'] ?? 'Login gagal, coba lagi.';
        _showStatusDialog(false, errorMessage);
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showStatusDialog(
        false,
        "Koneksi Gagal. Pastikan server berjalan di http://192.168.0.102:8081. Error: $e",
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ======================================================
  // UI - TETAP SAMA
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 100, 30, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 150,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.healing, size: 80, color: buttonTeal),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/dokter.png',
                      height: 220,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 80),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) =>
                          value!.isEmpty ? 'Username tidak boleh kosong' : null,
                      decoration: _inputDecoration('Username'),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Password tidak boleh kosong' : null,
                      decoration: _inputDecoration('Password'),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: paleAzure,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }
}
