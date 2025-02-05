// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<dynamic> updateBuild(
  BuildContext context, {
  required String buildId,
  required Map<String, String> fields,
  Uint8List? imageBytes,
  List<Uint8List>? additionalImagesBytes,
  List<dynamic>? removedImages,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: User not authenticated')),
    );
    return null;
  }

  final String url = 'https://passiondrivenbuilds.com/api/builds/$buildId';

  try {
    // Build the request body
    final Map<String, dynamic> body = Map.from(fields);

    if (removedImages != null && removedImages.isNotEmpty) {
      body['removed_images'] = removedImages;
    }

    if (imageBytes != null) {
      body['image'] = base64Encode(imageBytes);
    }

    if (additionalImagesBytes != null && additionalImagesBytes.isNotEmpty) {
      final List<String> newImagesBase64 = additionalImagesBytes
          .map((bytes) => base64Encode(bytes))
          .toList();
      body['added_images'] = newImagesBase64;
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final updatedBuild = jsonDecode(response.body)['build'];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Build updated successfully!')),
      );
      return updatedBuild;
    } else {
      final error =
          jsonDecode(response.body)['message'] ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      return null;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    return null;
  }
}
