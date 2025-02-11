import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';


Future<Map<String, dynamic>> fetchTagData({
  required BuildContext context,
  required int tagId,
}) async {
  final String apiUrl = 'https://passiondrivenbuilds.com/api/tags/$tagId';

  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to load tag data');
  }
}
