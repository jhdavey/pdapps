import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<Map<String, dynamic>> fetchGarageData({
  required BuildContext context,
  required int userId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  
  final String apiUrl = 'https://passiondrivenbuilds.com/api/garage/$userId';
  
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body);
    return decodedResponse;
  } else {
    throw Exception('Failed to load garage data');
  }
}
