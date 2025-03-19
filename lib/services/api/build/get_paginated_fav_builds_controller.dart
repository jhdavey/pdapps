import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth/auth_service.dart';

Future<List<dynamic>> fetchPaginatedFavoriteBuilds({
  required int page,
  int pageSize = 5,
  required BuildContext context,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  // Adjust the API URL as needed.
  final String apiUrl = 'https://passiondrivenbuilds.com/api/favorites/paginated?limit=$pageSize&page=$page';

  debugPrint('Token: $token');

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  debugPrint('Favorite paginated response status: ${response.statusCode}');
  debugPrint('Favorite paginated response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data is Map && data.containsKey('builds')) {
      return data['builds'] as List<dynamic>;
    } else if (data is List) {
      return data;
    } else {
      throw Exception('Invalid response format for paginated favorites');
    }
  } else {
    throw Exception('Failed to load paginated favorites: ${response.statusCode}');
  }
}
