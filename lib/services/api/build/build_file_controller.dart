// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Uploads a file for the build with [buildId].
/// Returns the uploaded file’s JSON object on success or `null` on error.
Future<Map<String, dynamic>?> uploadFile(
  BuildContext context, {
  required String buildId,
}) async {
  // Retrieve the auth token.
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: User not authenticated')),
    );
    return null;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null || result.files.single.path == null) {
    return null;
  }
  final filePath = result.files.single.path!;
  final String url = 'https://passiondrivenbuilds.com/api/builds/$buildId/files';

  try {
    // Create a multipart request.
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Attach the file.
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    // Send the request with a 30-second timeout.
    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully.')),
      );
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['file'];
    } else {
      final error = jsonDecode(responseBody)['message'] ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $error')),
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

Future<bool> deleteFile(
  BuildContext context, {
  required String fileId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: User not authenticated')),
    );
    return false;
  }

  final String url = 'https://passiondrivenbuilds.com/api/files/$fileId';

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully.')),
      );
      return true;
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $error')),
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
