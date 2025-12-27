import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Shared API client used across the app.
/// Adjust `baseUrl` as needed for emulator/device.
class Api {
  // Change this to the address reachable from your emulator/device if needed
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.3:8081',
  );

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? prefs.getString('access_token');
  }

  static Future<Map<String, String>> defaultHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty)
      headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final h = await defaultHeaders();
    return http.get(url, headers: h);
  }

  static Future<http.Response> post(
    String path, {
    Map<String, dynamic>? jsonBody,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final h = await defaultHeaders();
    h['Content-Type'] = 'application/json';
    return http.post(url, headers: h, body: json.encode(jsonBody ?? {}));
  }

  /// Generic multipart request (for file upload). Returns StreamedResponse.
  /// Example: await Api.multipart('/api/profile', files: {'profile_photo': file});
  static Future<http.StreamedResponse> multipart(
    String path, {
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest(method, url);
    final token = await _getToken();
    if (token != null && token.isNotEmpty)
      request.headers['Authorization'] = 'Bearer $token';

    if (fields != null) request.fields.addAll(fields);

    if (files != null) {
      for (final entry in files.entries) {
        final key = entry.key;
        final file = entry.value;
        request.files.add(await http.MultipartFile.fromPath(key, file.path));
      }
    }

    return request.send();
  }

  // Convenience helper for profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final res = await get('/api/profile');
    if (res.statusCode == 200)
      return json.decode(res.body) as Map<String, dynamic>;
    return null;
  }
}
