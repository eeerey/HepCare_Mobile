import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==================== KONFIGURASI TEMA ====================
const Color kBgGradientTop = Color(0xFFE0F2F7);
const Color kBgGradientBottom = Color(0xFFB2EBF2);
const Color kPrimaryBlue = Color(0xFF0D98A7);
const Color kTextDark = Color(0xFF2D3E50);

class QuestionData {
  final int id;
  final String questionText;
  final List<String> options;
  QuestionData({
    required this.id,
    required this.questionText,
    required this.options,
  });
}

final List<QuestionData> cdcQuestions = [
  QuestionData(
    id: 2,
    questionText:
        "Apakah Anda pernah didiagnosis menderita penyakit hati kronis?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 3,
    questionText:
        "Apakah Anda atau salah satu orang tua Anda lahir di luar Amerika Serikat?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 4,
    questionText:
        "Apakah Anda saat ini tinggal dengan seseorang yang terdiagnosis Hepatitis B?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 5,
    questionText:
        "Apakah Anda sebelumnya pernah tinggal dengan seseorang yang terdiagnosis Hepatitis B?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 6,
    questionText:
        "Apakah Anda baru saja didiagnosis menderita penyakit menular seksual (PMS)?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 7,
    questionText: "Apakah Anda didiagnosis menderita diabetes?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 8,
    questionText: "Apakah Anda didiagnosis menderita HIV/AIDS?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 9,
    questionText:
        "Jika Anda laki-laki, apakah Anda melakukan hubungan seksual dengan sesama laki-laki?",
    options: ["Iya", "Tidak"],
  ),
  QuestionData(
    id: 10,
    questionText: "Apakah Anda saat ini menggunakan narkoba suntik?",
    options: ["Iya", "Tidak"],
  ),
];

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kBgGradientTop, kBgGradientBottom],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// ==================== HALAMAN 1: START SCREEN ====================
class StartScreen extends StatelessWidget {
  final int userId;
  const StartScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: kPrimaryBlue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Kuisioner",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Icon(
                    Icons.medical_services,
                    size: 30,
                    color: kPrimaryBlue,
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.health_and_safety,
                size: 120,
                color: kPrimaryBlue,
              ),
              const SizedBox(height: 30),
              const Text(
                "Hepatitis B Health\nRisk Assessment",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Berdasarkan Standar CDC\n(Pusat Pengendalian Penyakit)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionScreen(userId: userId),
                    ),
                  ),
                  child: const Text("Mulai Sekarang"),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HALAMAN 2: QUESTION SCREEN ====================
class QuestionScreen extends StatefulWidget {
  final int userId;
  const QuestionScreen({super.key, required this.userId});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<int, String> _answers = {};

  Future<void> _submitAnswers() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      int iyaCount = 0;
      List<Map<String, dynamic>> payload = [];

      // Loop untuk menghitung skor dan membangun payload jawaban
      for (int i = 0; i < cdcQuestions.length; i++) {
        String ans = _answers[i] ?? "Tidak";
        if (ans == "Iya") iyaCount++;
        payload.add({
          "question_id": cdcQuestions[i].id,
          "answer": ans == "Iya" ? "Yes" : "No",
        });
      }

      // Tentukan label risiko
      String riskLevelLabel = (iyaCount >= 5)
          ? "Risiko Tinggi"
          : (iyaCount >= 2 ? "Risiko Sedang" : "Risiko Rendah");

      // Bangun body JSON secara eksplisit
      final Map<String, dynamic> requestBody = {
        "user_id": widget.userId,
        "risk_level": riskLevelLabel,
        "answers": payload,
      };

      final response = await http.post(
        Uri.parse('http://192.168.0.102:8081/api/cdc-screening'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              recommendations: result['recommendations'] ?? [],
              riskLevel: riskLevelLabel,
              score: iyaCount,
              userId: widget.userId,
            ),
          ),
        );
      } else {
        throw Exception("Server mengembalikan status: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup Loading jika error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cdcQuestions.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) =>
                    _buildQuestionCard(cdcQuestions[index], index),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kPrimaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Pertanyaan ${_currentIndex + 1}/${cdcQuestions.length}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "H-B",
            style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionData q, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 25),
            ...q.options.map((opt) => _buildOption(opt, index)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String opt, int qIndex) {
    bool isSelected = _answers[qIndex] == opt;
    return GestureDetector(
      onTap: () => setState(() => _answers[qIndex] = opt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? kPrimaryBlue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? kPrimaryBlue.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? kPrimaryBlue : Colors.grey,
            ),
            const SizedBox(width: 15),
            Text(
              opt,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? kPrimaryBlue : kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
                child: const Text("Kembali"),
              ),
            ),
          if (_currentIndex > 0) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_answers[_currentIndex] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pilih salah satu jawaban!")),
                  );
                  return;
                }
                _currentIndex == cdcQuestions.length - 1
                    ? _submitAnswers()
                    : _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
              },
              child: Text(
                _currentIndex == cdcQuestions.length - 1
                    ? "Lihat Hasil"
                    : "Selanjutnya",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HALAMAN 3: RESULT SCREEN ====================
class ResultScreen extends StatelessWidget {
  final List recommendations;
  final String riskLevel;
  final int score;
  final int userId;

  const ResultScreen({
    super.key,
    required this.recommendations,
    required this.riskLevel,
    required this.score,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    Color riskColor = riskLevel.contains("Tinggi")
        ? Colors.red
        : (riskLevel.contains("Sedang") ? Colors.orange : Colors.green);

    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "Hasil Analisis",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Icon(
                riskLevel.contains("Rendah")
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
                size: 100,
                color: riskColor,
              ),
              const SizedBox(height: 20),
              Text(
                riskLevel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Skor: $score indikator ditemukan",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rekomendasi Medis:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: recommendations.isEmpty
                    ? const Center(
                        child: Text(
                          "Tetap jaga pola hidup sehat dan konsultasi rutin.",
                        ),
                      )
                    : ListView.builder(
                        itemCount: recommendations.length,
                        itemBuilder: (context, i) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(
                              Icons.info_outline,
                              color: kPrimaryBlue,
                            ),
                            title: Text(
                              recommendations[i]['recommendation_detail'] ?? "",
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text("Selesai & Kembali"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
