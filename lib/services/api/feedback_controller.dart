import 'dart:convert';
import 'package:flutter/material.dart'; // For debugPrint.
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

    // Convert empty phone string to null.
    final requestBody = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone.isEmpty ? null : phone,
      'feedback': feedback,
    });
    debugPrint("Sending feedback with request body: $requestBody");

    final response = await http.post(
      uri,
      headers: headers,
      body: requestBody,
    );

    debugPrint("Feedback response status: ${response.statusCode}");
    debugPrint("Feedback response body: ${response.body}");

    if (response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Feedback submission failed');
    }
  }
}
