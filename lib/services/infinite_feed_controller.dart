import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/models/feed_item.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<Map<String, dynamic>> fetchPaginatedFeedItems({
  required BuildContext context,
  required int page,
}) async {
  const int pageSize = 10;
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  final response = await http.get(
    Uri.parse(
        'https://passiondrivenbuilds.com/api/feed?page=$page&limit=$pageSize'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  debugPrint("Feed response: ${response.body}");

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final List<dynamic> itemsRaw = decoded['data'] ?? [];
    final bool hasMore = decoded['has_more'] ?? false;

    final items =
        itemsRaw.map<FeedItem>((item) => FeedItem.fromJson(item)).toList();

    return {
      'items': items,
      'hasMore': hasMore,
    };
  } else {
    throw Exception('Failed to load feed items');
  }
}
