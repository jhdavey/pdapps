import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<List<dynamic>> fetchFollowers({
  required BuildContext context,
  required int userId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/users/$userId/followers';

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['followers'] as List<dynamic>?) ?? [];
  } else {
    throw Exception('Failed to load followers');
  }
}

Future<List<dynamic>> fetchFollowing({
  required BuildContext context,
  required int userId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/users/$userId/following';

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['following'] as List<dynamic>?) ?? [];
  } else {
    throw Exception('Failed to load following');
  }
}

Future<bool> toggleFollow({
  required BuildContext context,
  required int profileUserId,
  required bool isFollowing,
}) async {
  final bool follow = !isFollowing;
  String apiUrl;
  http.Response response;

  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  if (follow) {
    apiUrl = 'https://passiondrivenbuilds.com/api/users/$profileUserId/follow';
    response = await http.post(Uri.parse(apiUrl), headers: headers);
  } else {
    apiUrl =
        'https://passiondrivenbuilds.com/api/users/$profileUserId/unfollow';
    response = await http.delete(Uri.parse(apiUrl), headers: headers);
  }

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Error: ${response.body}');
  }
}
