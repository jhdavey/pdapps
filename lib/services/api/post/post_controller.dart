// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String _endpoint =
      'https://passiondrivenbuilds.com/api/build-posts';

  PostService();

  Future<http.StreamedResponse> createPost({
    required File mediaFile,
    required int buildId,
    required String caption,
    required List<String> tags,
  }) async {
    // 1) Grab saved token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No auth token stored.');
    }

    // 2) Build the URI (must exactly match your Laravel route:list entry)
    final uri = Uri.parse(_endpoint);

    // 3) Create a MultipartRequest, exactly like in submitModification()
    final request = http.MultipartRequest('POST', uri);

    // 4) Set headers: Accept + Authorization
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    // 5) Add the text fields that Laravel expects
    request.fields['build_id'] = buildId.toString();
    request.fields['caption'] = caption;
    request.fields['tags'] = tags.join(',');

    // 6) Add exactly one “media” file (Laravel is validating 'media')
    final mimeType =
        lookupMimeType(mediaFile.path) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mimeType);

    final multipartFile = await http.MultipartFile.fromPath(
      'media', // ← this key must match Laravel's validation rule: 'media'
      mediaFile.path,
      contentType: mediaType,
    );
    request.files.add(multipartFile);

    // 7) Send and return the streamed response
    return request.send();
  }

  Future<List<dynamic>> fetchPaginatedPostsForBuild({
    required String buildId,
    required int page,
    required int pageSize,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No auth token stored.');
    }

    final uri = Uri.parse('$_endpoint').replace(queryParameters: {
      'build_id': buildId,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      // Laravel returns { "data": [ … ], "current_page":…, ... }
      if (decoded.containsKey('data') && decoded['data'] is List) {
        return decoded['data'] as List<dynamic>;
      } else {
        return <dynamic>[];
      }
    } else {
      throw Exception(
        'Error fetching posts: [${response.statusCode}] ${response.body}',
      );
    }
  }

  Future<void> updatePost({
    required int postId,
    required String caption,
    required List<String> tags,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No auth token.');

    final uri = Uri.parse('$_endpoint/$postId');

    final response = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caption': caption,
        'tags': tags.join(','),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update post: ${response.body}');
    }
  }

  Future<void> deletePost({required int postId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No auth token.');

    final uri = Uri.parse('$_endpoint/$postId');
    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }

  Future<bool> likePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_endpoint/$postId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> unlikePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_endpoint/$postId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getPostComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint('No auth token found');
      return [];
    }

    final uri =
        Uri.parse('https://passiondrivenbuilds.com/api/posts/$postId/comments');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        debugPrint('Failed to load post comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching post comments: $e');
      return [];
    }
  }
}
