import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> loadBuildDataHelper(String buildId, BuildContext context) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/builds/$buildId';
  
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data;
  } else {
    debugPrint('Failed to load build data: ${response.body}');
    return null;
  }
}
