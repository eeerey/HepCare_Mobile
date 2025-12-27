import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/home.dart';
import 'fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase init error: $e');
  }

  // Initialize FCM Service
  try {
    await FcmService.initialize();
  } catch (e) {
    print('FCM init error: $e');
  }

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
