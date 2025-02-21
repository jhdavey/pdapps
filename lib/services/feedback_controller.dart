import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackController {
  final String baseUrl;
  FeedbackController({required this.baseUrl});

  Future<void> sendFeedback({
    required String name,
    required String email,
    required String phone,
    required String feedback,
  }) async {
    final uri = Uri.parse('$baseUrl/api/feedback');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    // Build headers with auth token if available.
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'feedback': feedback,
      }),
    );

    if (response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Feedback submission failed');
    }
  }
}
