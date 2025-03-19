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
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl =
    'https://passiondrivenbuilds.com/api/builds/paginated?limit=$pageSize&page=$page';

  debugPrint('Token: $token');

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  debugPrint('Response status: ${response.statusCode}');
  debugPrint('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data is Map && data.containsKey('builds')) {
      final builds = data['builds'] as List<dynamic>;
      debugPrint('Paginated builds returned: ${builds.length} items');
      return builds;
    } else if (data is List) {
      return data;
    } else {
      throw Exception('Invalid response format for paginated builds');
    }
  } else {
    throw Exception('Failed to load paginated builds: ${response.statusCode}');
  }
}

