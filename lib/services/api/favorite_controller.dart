import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<bool> addFavorite({
  required BuildContext context,
  required int buildId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('No auth token available.');
  }
  final String apiUrl = 'https://passiondrivenbuilds.com/api/favorites';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'build_id': buildId}),
  );

  // Debug log: print status code and response body.
  debugPrint("AddFavorite status: ${response.statusCode}");
  debugPrint("AddFavorite response: ${response.body}");

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to add favorite: ${response.body}');
  }
}

Future<bool> removeFavorite({
  required BuildContext context,
  required int buildId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('No auth token available.');
  }
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/favorites/$buildId';

  final response = await http.delete(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  debugPrint("RemoveFavorite status: ${response.statusCode}");
  debugPrint("RemoveFavorite response: ${response.body}");

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to remove favorite: ${response.body}');
  }
}
