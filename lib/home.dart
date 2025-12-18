import 'package:flutter/material.dart';
// Baris ini diperbaiki: Menggunakan nama file yang benar (login_page.dart)
// Asumsi file ini berada di folder yang sama atau diakses melalui path yang sama.
import 'register.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HepCare App',
      // Menghilangkan banner "DEBUG" di sudut kanan atas
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menentukan warna primer aplikasi (digunakan jika tidak di-override)
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna yang digunakan dalam desain
    const Color buttonYellow = Color(0xFFFFC107);
    const Color buttonTeal = Color(0xFF009688);

    return Scaffold(
      body: Container(
        // Latar belakang gradient sesuai desain
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Warna-warna yang mendekati desain Anda
            colors: [
              Color(0xFFE3F2FD), // Biru muda di atas (Mirip BG desain)
              Color(0xFFE8F5E9), // Hijau muda di bawah (Mirip BG desain)
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100), // Spasi atas
                // 1. Logo HepCare (menggunakan aset gambar)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 20),
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 250,
                  ),
                  child: Image.asset(
                    'assets/logo.png', // Pastikan path ini benar
                    fit: BoxFit.contain,
                  ),
                ),

                // 2. Gambar Ilustrasi Dokter (menggunakan aset gambar)
                // Di sini kami memperbaiki struktur widget
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  width: double.infinity,
                  child: Image.asset(
                    'assets/dokter.png', // Pastikan path ini benar
                    fit: BoxFit.contain,
                  ),
                ),

                // 3. Tombol LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // BAGIAN INI DIBENARKAN:
                      // Mengganti 'login()' dengan 'LoginPage()' (PascalCase)

                      // Menggunakan Navigator.pushReplacement untuk pindah halaman Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          // Sekarang memanggil LoginPage yang benar
                          builder: (context) => const HepCareLoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
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

                const SizedBox(height: 15),

                // 4. Tombol REGISTER
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // BAGIAN INI DIBENARKAN:
                      // Mengganti 'login()' dengan 'LoginPage()' (PascalCase)

                      // Menggunakan Navigator.pushReplacement untuk pindah halaman Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          // Sekarang memanggil LoginPage yang benar
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Teks 'Atau Login dengan'
                const Text(
                  'Atau Login dengan',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 15),

                // 6. Tombol Login Sosial Media (Google & Facebook)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Tombol Google
                    SocialButton(
                      // Menggunakan ikon 'G' bawaan sebagai placeholder
                      icon: Icons.g_mobiledata,
                      iconColor: Colors.blue,
                      onPressed: () {
                        print('Login dengan Google');
                      },
                    ),
                    const SizedBox(width: 20),
                    // Tombol Facebook
                    SocialButton(
                      icon: Icons.facebook,
                      iconColor: Colors.blue[800],
                      onPressed: () {
                        print('Login dengan Facebook');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget khusus untuk tombol sosial media
class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
