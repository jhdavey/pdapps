// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<bool> createBuild(
  BuildContext context, {
  required Map<String, dynamic> fields,
  File? imageFile,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: User not authenticated')),
    );
    return false;
  }

  // URL for creating a build.
  final url = 'https://passiondrivenbuilds.com/api/builds';

  try {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    // Add the authorization header.
    request.headers['Authorization'] = 'Bearer $token';

    // If a tags field is provided as a comma-separated string,
    // split it and add each tag individually.
    if (fields.containsKey('tags') && fields['tags'] is String) {
      final tagsInput = fields['tags'] as String;
      final List<String> tags = tagsInput
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      // Remove the original 'tags' entry.
      fields.remove('tags');
      // Add each tag as a separate field.
      for (int i = 0; i < tags.length; i++) {
        request.fields['tags[$i]'] = tags[i];
      }
    }

    // Add the remaining fields.
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // If an image file was selected, add it to the request.
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Build created successfully!')),
      );
      return true;
    } else {
      final responseBody = await response.stream.bytesToString();
      final error = jsonDecode(responseBody)['message'] ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    return false;
  }
}
