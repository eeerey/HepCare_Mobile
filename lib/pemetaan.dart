import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PemetaanPage extends StatefulWidget {
  const PemetaanPage({super.key});

  @override
  State<PemetaanPage> createState() => _PemetaanPageState();
}

class _PemetaanPageState extends State<PemetaanPage> {
  List<Polygon> _polygons = [];
  List<Marker> _markers = [];
  bool _isLoading = true;
  String _errorMessage = "";
  Map<String, dynamic>? _selectedProvinceData;

  @override
  void initState() {
    super.initState();
    _fetchGeoJsonData();
  }

  Future<void> _fetchGeoJsonData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _selectedProvinceData = null;
    });

    try {
      // 1. PASTIKAN IP sesuai dengan hasil 'ipconfig' di laptop
      // 2. PASTIKAN Port sesuai dengan app.run(port=...) di Flask
      // 3. PASTIKAN Route sesuai dengan @map_bp.route(...) di Flask
      const String baseUrl =
          "http://192.168.0.102:8081"; // Kembali ke 5000 jika Flask default
      const String endpoint = "/api/mobile/peta";

      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (data['status'] == 'success' && data['geojson'] != null) {
          _processGeoJson(data['geojson']);
        } else {
          setState(() => _errorMessage = "Data kosong atau format salah.");
        }
      } else {
        setState(() => _errorMessage = "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(
        () => _errorMessage =
            "Koneksi Gagal.\n1. Pastikan bisa buka URL di Chrome HP\n2. Cek Firewall Laptop\n3. Cek IP Laptop",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processGeoJson(Map<String, dynamic> geojson) {
    final List features = geojson['features'] ?? [];
    List<Polygon> newPolygons = [];
    List<Marker> newMarkers = [];

    for (var feature in features) {
      final props = feature['properties'] ?? {};
      final geom = feature['geometry'];
      if (geom == null) continue;

      Color polyColor = _getColor(props['kelas_risiko']);
      final type = geom['type'];
      final coords = geom['coordinates'];
      List<LatLng> allPoints = [];

      if (type == 'Polygon') {
        for (var ring in coords) {
          List<LatLng> points = _convertToLatLng(ring);
          allPoints.addAll(points);
          newPolygons.add(_createPolygon(points, polyColor));
        }
      } else if (type == 'MultiPolygon') {
        for (var poly in coords) {
          for (var ring in poly) {
            List<LatLng> points = _convertToLatLng(ring);
            allPoints.addAll(points);
            newPolygons.add(_createPolygon(points, polyColor));
          }
        }
      }

      if (allPoints.isNotEmpty) {
        newMarkers.add(
          _createInteractiveMarker(_calculateCentroid(allPoints), props),
        );
      }
    }

    setState(() {
      _polygons = newPolygons;
      _markers = newMarkers;
    });
  }

  // --- UI HELPERS ---

  Marker _createInteractiveMarker(LatLng point, Map<String, dynamic> props) {
    return Marker(
      point: point,
      width: 120,
      height: 40,
      child: GestureDetector(
        onTap: () => setState(() => _selectedProvinceData = props),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26, width: 0.5),
            ),
            child: Text(
              props['nama_provinsi'] ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPopup() {
    if (_selectedProvinceData == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedProvinceData!['nama_provinsi'] ?? "Detail",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        setState(() => _selectedProvinceData = null),
                  ),
                ],
              ),
              const Divider(),
              _infoTile(
                Icons.vaccines,
                "Imunisasi",
                "${_selectedProvinceData!['persentase_imunisasi'] ?? '-'} %",
              ),
              _infoTile(
                Icons.warning,
                "Risiko",
                _selectedProvinceData!['kelas_risiko'] ?? "N/A",
                isStatus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    Color statusColor = isStatus ? _getColor(value) : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: isStatus ? statusColor : Colors.blue),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor,
          fontSize: 15,
        ),
      ),
    );
  }

  Color _getColor(String? risiko) {
    switch (risiko) {
      case "Tinggi":
        return Colors.red;
      case "Sedang":
        return Colors.orange;
      case "Rendah":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<LatLng> _convertToLatLng(dynamic ring) {
    return (ring as List)
        .map(
          (pos) =>
              LatLng((pos[1] as num).toDouble(), (pos[0] as num).toDouble()),
        )
        .toList();
  }

  Polygon _createPolygon(List<LatLng> points, Color color) {
    return Polygon(
      points: points,
      color: color.withOpacity(0.3),
      borderColor: color,
      borderStrokeWidth: 1.5,
      isFilled: true,
    );
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (var p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Peta Risiko Hepatitis")),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-2.5, 118.0),
              initialZoom: 4.8,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                // FIX WARNING RETINA MODE:
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              PolygonLayer(polygons: _polygons),
              MarkerLayer(markers: _markers),
            ],
          ),
          _buildDetailPopup(),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty) _buildErrorWidget(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(_errorMessage, textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: _fetchGeoJsonData,
                child: const Text("Refresh"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
