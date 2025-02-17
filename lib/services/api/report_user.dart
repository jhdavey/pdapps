import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Reports a user by sending their ID to your API.
/// This endpoint requires an authenticated user.
Future<void> reportUser(Map<String, dynamic> user, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not authenticated.")),
    );
    return;
  }

  final userId = user['id'];
  try {
    final response = await http.post(
      Uri.parse("https://passiondrivenbuilds.com/api/report-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"user_id": userId.toString()}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User reported successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to report user.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error reporting user: $e")),
    );
  }
}

Future<void> blockUser(Map<String, dynamic> user, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not authenticated.")),
    );
    return;
  }

  final userId = user['id'];
  try {
    final response = await http.post(
      Uri.parse("https://passiondrivenbuilds.com/api/block-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"user_id": userId.toString()}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User blocked successfully.")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to block user.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error blocking user: $e")),
    );
  }
}

