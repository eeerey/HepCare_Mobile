import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  final String username;
  const HistoryPage({super.key, required this.username});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List historyData = [];
  bool isLoading = true;

  final String baseUrl = "http://192.168.0.103:8000";

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/history/$userId'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            historyData = json.decode(response.body);
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error Fetch History: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Helper untuk menentukan warna berdasarkan teks Risk Level
  Color _getRiskColor(String? riskLevel) {
    if (riskLevel == null) return Colors.grey;
    if (riskLevel.contains("Tinggi")) return Colors.red;
    if (riskLevel.contains("Sedang")) return Colors.orange;
    if (riskLevel.contains("Rendah")) return Colors.green;
    return Colors.blue;
  }

  void _showDetail(Map<String, dynamic> item) {
    String riskLabel = item['risk_level'] ?? "Tidak Diketahui";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Detail Pemeriksaan #${item['id']}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              _detailRow("Waktu", item['date'] ?? "-"),
              _detailRow(
                "Tingkat Risiko",
                riskLabel,
                isBold: true,
                textColor: _getRiskColor(riskLabel),
              ),
              const SizedBox(height: 15),
              const Text(
                "Keterangan:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                riskLabel.contains("Tinggi")
                    ? "Sangat disarankan untuk segera melakukan tes laboratorium HBsAg dan berkonsultasi dengan dokter spesialis penyakit dalam."
                    : "Tetap jaga pola hidup sehat dan lakukan pemeriksaan rutin secara berkala.",
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D98A7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "TUTUP",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Pemeriksaan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D98A7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyData.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final item = historyData[index];
                  return _buildHistoryCard(item, index);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat untuk ${widget.username}",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    String riskLabel = item['risk_level'] ?? "Hasil Normal";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: _getRiskColor(riskLabel).withOpacity(0.1),
          child: Icon(Icons.assignment, color: _getRiskColor(riskLabel)),
        ),
        title: Text(
          "Pemeriksaan #${item['id']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Waktu: ${item['date'] ?? '-'}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRiskColor(riskLabel).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                riskLabel,
                style: TextStyle(
                  color: _getRiskColor(riskLabel),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showDetail(item),
      ),
    );
  }
}
