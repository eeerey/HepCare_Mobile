import 'package:flutter/material.dart';

const Color hepCareBlue = Color(0xFF1E88E5);
const Color primaryLightBlue = Color(0xFFE3F2FD);
const Color hepCareGreen = Color(0xFF4CAF50);

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'Bagaimana cara mengisi kuis kesehatan?',
      answer:
          'Navigasi ke halaman "Kuis" di menu utama. Jawab semua pertanyaan dengan jujur sesuai kondisi kesehatan Anda. '
          'Setelah selesai, sistem akan memberikan penilaian risiko berdasarkan jawaban Anda.',
      category: 'Kuis Kesehatan',
    ),
    FAQItem(
      question: 'Apa arti tingkat risiko yang ditampilkan?',
      answer:
          'Tingkat risiko menunjukkan kemungkinan kondisi kesehatan hati berdasarkan jawaban Anda. '
          'Tingkat risiko dibagi menjadi beberapa kategori: Rendah (hijau), Sedang (kuning), Tinggi (oranye), dan Sangat Tinggi (merah). '
          'Jika hasil menunjukkan risiko tinggi, segera konsultasikan dengan dokter.',
      category: 'Kuis Kesehatan',
    ),
    FAQItem(
      question: 'Bagaimana cara melihat riwayat pemeriksaan saya?',
      answer:
          'Buka menu "Riwayat" untuk melihat semua pemeriksaan yang telah Anda lakukan. '
          'Setiap pemeriksaan menampilkan tanggal, tingkat risiko, dan ringkasan hasil. '
          'Ketuk salah satu untuk melihat detail lengkap.',
      category: 'Riwayat Pemeriksaan',
    ),
    FAQItem(
      question: 'Bisakah saya mengubah data profil saya?',
      answer:
          'Ya, Anda dapat mengubah data profil dengan membuka halaman "Profil" dan menekan tombol "Edit Profile". '
          'Anda dapat mengubah nama lengkap, email, nomor telepon, tanggal lahir, dan foto profil.',
      category: 'Profil & Pengaturan',
    ),
    FAQItem(
      question: 'Bagaimana cara mengaktifkan notifikasi artikel terbaru?',
      answer:
          'Buka halaman "Profil", pilih "Notification Preferences", dan aktifkan toggle "Aktifkan Notifikasi". '
          'Setelah diaktifkan, Anda akan menerima notifikasi ketika ada artikel kesehatan terbaru.',
      category: 'Notifikasi',
    ),
    FAQItem(
      question: 'Bagaimana cara menemukan rumah sakit terdekat?',
      answer:
          'Buka halaman "Pemetaan" untuk melihat peta rumah sakit di sekitar Anda. '
          'Aplikasi akan menampilkan lokasi Anda saat ini dan rumah sakit-rumah sakit terdekat dengan informasi nama dan alamat.',
      category: 'Pemetaan',
    ),
    FAQItem(
      question: 'Apakah data saya aman di aplikasi ini?',
      answer:
          'Ya, keamanan data Anda adalah prioritas utama kami. Semua komunikasi dienkripsi dan data disimpan secara aman di server. '
          'Kami tidak membagikan data pribadi Anda kepada pihak ketiga tanpa persetujuan.',
      category: 'Keamanan & Privasi',
    ),
    FAQItem(
      question: 'Bagaimana cara menghubungi dukungan pelanggan?',
      answer:
          'Anda dapat menghubungi tim dukungan kami melalui email di support@hepcare.com atau mengisi formulir kontak di aplikasi. '
          'Kami akan merespons pertanyaan Anda dalam waktu 24 jam.',
      category: 'Dukungan',
    ),
    FAQItem(
      question: 'Bagaimana cara logout dari akun saya?',
      answer:
          'Buka halaman "Profil", scroll ke bawah, dan pilih "Log Out". Konfirmasikan logout Anda dan Anda akan diarahkan ke halaman login.',
      category: 'Akun',
    ),
    FAQItem(
      question: 'Bisakah saya menghapus akun saya?',
      answer:
          'Untuk menghapus akun, silakan hubungi tim dukungan kami. Kami akan membantu Anda melalui proses penghapusan akun. '
          'Harap diperhatikan bahwa data Anda tidak dapat dipulihkan setelah dihapus.',
      category: 'Akun',
    ),
  ];

  String selectedCategory = 'Semua';
  List<FAQItem> filteredFAQ = [];

  @override
  void initState() {
    super.initState();
    filteredFAQ = faqItems;
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'Semua') {
        filteredFAQ = faqItems;
      } else {
        filteredFAQ = faqItems
            .where((item) => item.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Semua',
      ...faqItems.map((item) => item.category).toSet(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: primaryLightBlue),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Bantuan & FAQ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENT ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // --- SEARCH BAR ---
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari pertanyaan...',
                        hintStyle: TextStyle(color: Colors.black38),
                        prefixIcon: Icon(Icons.search, color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _filterByCategory(selectedCategory);
                          } else {
                            filteredFAQ = faqItems
                                .where(
                                  (item) =>
                                      item.question.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ) ||
                                      item.answer.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ),
                                )
                                .toList();
                          }
                        });
                      },
                    ),
                  ),

                  // --- CATEGORY FILTER ---
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              _filterByCategory(category);
                            },
                            backgroundColor: Colors.white,
                            selectedColor: hepCareGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? hepCareGreen : Colors.black12,
                              width: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- FAQ LIST ---
                  if (filteredFAQ.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada pertanyaan yang cocok',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredFAQ.length,
                      itemBuilder: (context, index) {
                        return FAQItemWidget(item: filteredFAQ[index]);
                      },
                    ),

                  const SizedBox(height: 20),

                  // --- CONTACT SUPPORT ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: hepCareBlue.withOpacity(0.1),
                      border: Border.all(
                        color: hepCareBlue.withOpacity(0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: hepCareBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.mail_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Hubungi Dukungan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Jika pertanyaan Anda tidak dijawab di sini, hubungi tim dukungan kami:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Email: support@hepcare.com',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Nomor Telepon: +62-800-1234-5678',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FAQItemWidget extends StatefulWidget {
  final FAQItem item;

  const FAQItemWidget({super.key, required this.item});

  @override
  State<FAQItemWidget> createState() => _FAQItemWidgetState();
}

class _FAQItemWidgetState extends State<FAQItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            widget.item.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.item.category,
              style: const TextStyle(
                fontSize: 11,
                color: hepCareBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: hepCareBlue,
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: Colors.black12,
                    margin: const EdgeInsets.only(bottom: 12),
                  ),
                  Text(
                    widget.item.answer,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.6,
                    ),
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
