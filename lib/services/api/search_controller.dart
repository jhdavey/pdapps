// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> searchBuilds(BuildContext context, String query) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final String url = 'https://passiondrivenbuilds.com/api/search?q=$query';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['builds'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
      return [];
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    return [];
  }
}
