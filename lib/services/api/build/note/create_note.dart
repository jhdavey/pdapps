// submit_note.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<bool> submitNote({
  required BuildContext context,
  required int buildId,
  required String note,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/builds/$buildId/notes';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'note': note}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    return false;
  }
}

Future<String> uploadImage(File file, BuildContext context) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  final uri = Uri.parse('https://passiondrivenbuilds.com/api/media/upload');
  final request = http.MultipartRequest('POST', uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  // Use field name 'file' as defined in your Laravel controller.
  request.files.add(await http.MultipartFile.fromPath('file', file.path));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    return data['location']; // Return the image URL.
  } else {
    throw Exception('Image upload failed: ${response.statusCode} ${response.body}');
  }
}
