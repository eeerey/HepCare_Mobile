import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class AuthService {
  final String baseUrl =
      'http://10.0.2.2:5000/api/auth'; // Sesuaikan port dan IP jika perlu

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final accessToken = data['access_token'];
      final user = UserModel.fromJson(data['user']);

      return {'success': true, 'access_token': accessToken, 'user': user};
    } else {
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'error_message':
            errorData['error'] ??
            'Login gagal. Status code: ${response.statusCode}',
      };
    }
  }
}
