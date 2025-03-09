import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<Map<String, dynamic>> fetchBuildData(
    {required BuildContext context}) async {
  const String apiUrl = 'https://passiondrivenbuilds.com/api/builds';

  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  debugPrint('Token: $token');

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
    throw Exception('Failed to load builds');
  }
}

Future<List<dynamic>> fetchPaginatedBuilds({
  required int page,
  int pageSize = 5,
  required BuildContext context,
}) async {
  // Construct the API URL with query parameters for pagination.
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds?limit=$pageSize&page=$page';
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  debugPrint('Token: $token');

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Assuming the paginated response returns a Map with a "builds" key.
    if (data is Map && data.containsKey('builds')) {
      return data['builds'] as List<dynamic>;
    } else if (data is List) {
      // Fallback in case your API returns a List directly.
      return data;
    } else {
      throw Exception('Invalid response format for paginated builds');
    }
  } else {
    throw Exception('Failed to load paginated builds: ${response.statusCode}');
  }
}
