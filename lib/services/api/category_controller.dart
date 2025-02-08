import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<List<dynamic>> fetchBuildsByCategory({
  required BuildContext context,
  required String category,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  final String apiUrl =
      'https://passiondrivenbuilds.com/api/categories/${Uri.encodeComponent(category)}';

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['builds'] ?? []) as List<dynamic>;
  } else {
    throw Exception('Failed to load builds for category $category');
  }
}
