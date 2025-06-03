// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth/auth_service.dart';

Future<bool> postCommentOnPost(
  BuildContext context,
  String postId,
  String body, {
  int? parentId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/posts/$postId/comments';

  final Map<String, dynamic> bodyData = {'body': body};
  if (parentId != null) {
    bodyData['parent_id'] = parentId;
  }

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(bodyData),
    );

    return response.statusCode == 201;
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    return false;
  }
}

Future<bool> updatePostComment(
  BuildContext context,
  int commentId,
  String updatedBody,
) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/post-comments/$commentId';

  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'body': updatedBody}),
    );
    return response.statusCode == 200;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    return false;
  }
}

Future<bool> deletePostComment(
  BuildContext context,
  int commentId,
) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/post-comments/$commentId';

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    return false;
  }
}
