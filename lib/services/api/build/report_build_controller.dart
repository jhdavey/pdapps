import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> reportBuild(
    Map<String, dynamic> build, BuildContext context) async {
  final buildId = build['id'];
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.post(
      Uri.parse("https://passiondrivenbuilds.com/api/report-content"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({"build_id": buildId.toString()}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Build reported successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to report build.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error reporting build: $e")),
    );
  }
}
