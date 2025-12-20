import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // 💡 BARU: Untuk tipe File
import 'package:image_picker/image_picker.dart'; // 💡 BARU: Untuk ambil foto

// --- KONSTANTA DAN DEFINISI WARNA ---
const Color primaryLightBlue = Color(0xFFE3F2FD);
const Color hepCareBlue = Color(0xFF1E88E5);
const Color hepCareGreen = Color(0xFF4CAF50);
const Color buttonBlue = Color(0xFFB3E5FC);
const Color hepCareRed = Color(0xFFE53935);

// --- KONFIGURASI API ---
const String API_BASE_URL =
    'http://192.168.0.102:8081'; // Contoh untuk Android Emulator

// --- WIDGET UTAMA (Stateful) ---
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // STATE MANAGEMENT
  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentPhotoUrl;
  File? _selectedImage; // 💡 BARU: State untuk gambar yang baru dipilih

  // CONTROLLERS
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU: AMBIL GAMBAR DARI GALERI ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto profil berhasil dipilih. Tekan Simpan untuk mengunggah.',
          ),
          backgroundColor: hepCareGreen,
        ),
      );
    }
  }

  // --- FUNGSI HTTP (GET) ---
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('jwt_token');

    if (authToken == null) {
      // Handle jika tidak ada token (contoh: navigasi ke login)
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final url = Uri.parse('$API_BASE_URL/api/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _currentPhotoUrl = data['photoUrl'];

          // Memformat tanggal
          String rawDate = data['birthDate'] ?? '';
          if (rawDate.isNotEmpty) {
            try {
              DateTime date = DateTime.parse(rawDate);
              _dobController.text = DateFormat('dd/MM/yyyy').format(date);
            } catch (_) {
              _dobController.text = rawDate;
            }
          }
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          // Tampilkan error
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Tampilkan error jaringan
      }
    }
  }

  // --- FUNGSI BARU: HTTP (MULTI-PART PUT) UNTUK TEKS & FOTO ---
  void _handleSaveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // 1. Re-format Tanggal (DD/MM/YYYY -> YYYY-MM-DD)
    String formattedDateForApi = _dobController.text;
    try {
      DateTime dateObj = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      formattedDateForApi = DateFormat('yyyy-MM-dd').format(dateObj);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('jwt_token');

    if (authToken == null) {
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    // 2. Buat permintaan Multipart
    final url = Uri.parse('$API_BASE_URL/api/profile');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $authToken';

    // 3. Tambahkan data teks ke fields
    request.fields['fullName'] = _nameController.text;
    request.fields['username'] = _usernameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['birthDate'] = formattedDateForApi;
    request.fields['phoneNumber'] = _phoneController.text;

    // 4. Tambahkan file gambar jika ada yang dipilih
    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo', // ⚠️ PASTIKAN NAMA FIELD INI SAMA DENGAN NAMA FIELD DI API FLASK ANDA!
          _selectedImage!.path,
        ),
      );
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      // Jika tidak ada gambar baru, tapi ada gambar lama, kirim URL gambar lama
      // (Ini tergantung implementasi API, tapi umumnya lebih baik tidak mengirim apa-apa jika tidak berubah)
      request.fields['photoUrl'] = _currentPhotoUrl!;
    }

    // 5. Kirim Request
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }

      if (response.statusCode == 200) {
        // Hapus gambar lokal yang sudah diunggah
        setState(() {
          _selectedImage = null;
        });
        // Muat ulang data profil untuk mendapatkan URL foto yang baru
        _fetchUserProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil dan Foto berhasil diperbarui!'),
            backgroundColor: hepCareGreen,
          ),
        );
      } else {
        final errorMsg =
            responseData['error'] ??
            'Gagal menyimpan. Kode: ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: hepCareRed),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error jaringan saat menyimpan: $e'),
            backgroundColor: hepCareRed,
          ),
        );
      }
    }
  }

  // --- FUNGSI DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    try {
      final parts = _dobController.text.split('/');
      if (parts.length == 3) {
        initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: hepCareBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Menentukan Image Provider:
    // 1. File yang baru dipilih (_selectedImage)
    // 2. Network Image dari server (_currentPhotoUrl)
    // 3. Null (jika tidak ada keduanya)
    ImageProvider? profileImageProvider;
    if (_selectedImage != null) {
      profileImageProvider = FileImage(_selectedImage!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      profileImageProvider = NetworkImage(_currentPhotoUrl!);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: primaryLightBlue),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- HEADER ---
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
                    const Text.rich(
                      TextSpan(
                        text: 'Hep',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: hepCareBlue,
                        ),
                        children: [
                          TextSpan(
                            text: 'Care',
                            style: TextStyle(color: hepCareGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Judul Halaman
              const Padding(
                padding: EdgeInsets.only(top: 24.0, bottom: 20.0),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // 💡 AREA FOTO PROFIL (SUDAH INTERAKTIF)
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
                      child: Container(
                        color: Colors.grey[300],
                        child: profileImageProvider != null
                            ? Image(
                                image: profileImageProvider,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: hepCareBlue,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person_off,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,
                    // 💡 MEMBUNGKUS IKON DENGAN InkWell
                    child: InkWell(
                      onTap: _pickImage, // Panggil fungsi pilih gambar
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryLightBlue, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: hepCareBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Nama (Loading)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 30.0),
                child: Text(
                  _nameController.text.isEmpty && _isLoading
                      ? 'Memuat...'
                      : _nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // --- Bagian Form Input ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(25.0),
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
                child: _isLoading
                    ? const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: hepCareBlue),
                            SizedBox(height: 10),
                            Text(
                              'Memuat data profil...',
                              style: TextStyle(color: hepCareBlue),
                            ),
                          ],
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Nama
                            const Text(
                              'Nama Lengkap',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            CustomTextFieldWithController(
                              controller: _nameController,
                              validator: (value) => value!.isEmpty
                                  ? 'Nama tidak boleh kosong'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Email (Read-only)
                            const Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            CustomTextFieldWithController(
                              controller: _emailController,
                              isReadOnly: true,
                              validator: (value) =>
                                  value!.isEmpty || !value.contains('@')
                                  ? 'Email tidak valid'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Tanggal Lahir & Username
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tanggal Lahir',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextFieldWithController(
                                        controller: _dobController,
                                        isReadOnly: true,
                                        suffixIcon: Icons.calendar_today,
                                        onTap: () => _selectDate(context),
                                        validator: (value) => value!.isEmpty
                                            ? 'Tanggal lahir tidak boleh kosong'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Username',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextFieldWithController(
                                        controller: _usernameController,
                                        validator: (value) => value!.isEmpty
                                            ? 'Username tidak boleh kosong'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // No Telepon
                            const Text(
                              'No. Telepon (Opsional)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            CustomTextFieldWithController(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 40),

                            // Tombol Simpan Perubahan
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : _handleSaveProfile, // Panggil _handleSaveProfile
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black54,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.save,
                                        color: Colors.black54,
                                      ),
                                label: Text(
                                  _isSaving
                                      ? 'Menyimpan...'
                                      : 'Simpan Perubahan',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Tombol Ubah Password
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigasi ke halaman Ubah Password
                                  debugPrint('Navigasi ke Ubah Password');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryLightBlue.withOpacity(
                                    0.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Ubah Password',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET KUSTOM FIELD (Tidak ada perubahan) ---
class CustomTextFieldWithController extends StatelessWidget {
  final TextEditingController controller;
  final bool isReadOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextFieldWithController({
    super.key,
    required this.controller,
    this.isReadOnly = false,
    this.suffixIcon,
    this.onTap,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        filled: true,
        fillColor: isReadOnly ? Colors.grey[50] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hepCareBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hepCareRed, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hepCareRed, width: 2.0),
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.black54)
            : null,
      ),
    );
  }
}
