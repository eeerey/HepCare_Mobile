import 'package:flutter/material.dart';
// PENTING: Import file halaman yang baru dibuat
import '/home.dart';
// Catatan: Ganti 'nama_proyek_anda' dengan nama proyek Flutter Anda (dilihat di pubspec.yaml)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HepCare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Panggil Home sebagai halaman utama (yang diimpor dari '/home.dart')
      home: const Home(),
    );
  }
}
