import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'api.dart'; // Pastikan file api.dart berisi class Api dengan baseUrl

// --- KONSTANTA DAN DEFINISI WARNA ---
const Color primaryLightBlue = Color(0xFFE3F2FD);
const Color hepCareBlue = Color(0xFF1E88E5);
const Color hepCareGreen = Color(0xFF4CAF50);
const Color buttonBlue = Color(0xFFB3E5FC);
const Color hepCareRed = Color(0xFFE53935);

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
  File? _selectedImage;

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

  // --- FUNGSI AMBIL GAMBAR ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- FUNGSI HTTP (GET PROFILE) ---
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('jwt_token');

    if (authToken == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/profile'),
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
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI SAVE PROFILE ---
  void _handleSaveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    String formattedDateForApi = _dobController.text;
    try {
      DateTime dateObj = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      formattedDateForApi = DateFormat('yyyy-MM-dd').format(dateObj);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('jwt_token');

    final url = Uri.parse('${Api.baseUrl}/api/profile');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $authToken';

    request.fields['fullName'] = _nameController.text;
    request.fields['username'] = _usernameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['birthDate'] = formattedDateForApi;
    request.fields['phoneNumber'] = _phoneController.text;

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          _selectedImage!.path,
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (mounted) {
        setState(() => _isSaving = false);
        if (response.statusCode == 200) {
          _fetchUserProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: hepCareGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- FUNGSI DIALOG UBAH PASSWORD (FULL API & NO ERROR) ---
  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final passwordFormKey = GlobalKey<FormState>();

    // Inisialisasi variabel state untuk dialog
    bool obscureOld = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Ubah Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: passwordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Field Password Lama
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: obscureOld,
                      decoration: InputDecoration(
                        labelText: 'Password Lama',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureOld
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureOld = !obscureOld;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),
                    // Field Password Baru
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          value!.length < 6 ? 'Minimal 6 karakter' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hepCareBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (passwordFormKey.currentState!.validate()) {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final String? authToken = prefs.getString('jwt_token');

                        // ENDPOINT API (Sesuaikan jika backend berbeda)
                        final response = await http.post(
                          Uri.parse('${Api.baseUrl}/api/change-password'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $authToken',
                          },
                          body: jsonEncode({
                            'old_password': oldPasswordController.text,
                            'new_password': newPasswordController.text,
                          }),
                        );

                        if (response.statusCode == 200) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password berhasil diperbarui'),
                                backgroundColor: hepCareGreen,
                              ),
                            );
                          }
                        } else {
                          final errorMsg =
                              jsonDecode(response.body)['message'] ??
                              'Gagal mengubah password';
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMsg),
                                backgroundColor: hepCareRed,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error koneksi ke server'),
                              backgroundColor: hepCareRed,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
    } catch (_) {}
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null)
      setState(
        () => _dobController.text = DateFormat('dd/MM/yyyy').format(picked),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    ImageProvider? profileImageProvider;
    if (_selectedImage != null)
      profileImageProvider = FileImage(_selectedImage!);
    else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
      profileImageProvider = NetworkImage(_currentPhotoUrl!);

    return Scaffold(
      body: Container(
        color: primaryLightBlue,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.07,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              // Foto Profil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImageProvider,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: hepCareBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Form Input
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nama Lengkap',
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              isReadOnly: true,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _dobController,
                                    label: 'Tgl Lahir',
                                    isReadOnly: true,
                                    suffixIcon: Icons.calendar_today,
                                    onTap: () => _selectDate(context),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _usernameController,
                                    label: 'Username',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              controller: _phoneController,
                              label: 'No. Telepon',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 30),
                            // Tombol Simpan Profil
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : _handleSaveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonBlue,
                                ),
                                child: Text(
                                  _isSaving
                                      ? 'Menyimpan...'
                                      : 'Simpan Perubahan',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Tombol Ubah Password
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _showChangePasswordDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryLightBlue,
                                ),
                                child: const Text(
                                  'Ubah Password',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isReadOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isReadOnly = false,
    this.suffixIcon,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
