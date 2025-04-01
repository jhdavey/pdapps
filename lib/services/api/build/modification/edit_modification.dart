// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth/auth_service.dart';

Future<bool> updateModification({
  required BuildContext context,
  required int buildId,
  required int modificationId,
  required Map<String, dynamic> modificationData,
  List? newImages, // List of XFile objects for any new images.
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  // Clean up the price field if provided.
  if (modificationData['price'] != null) {
    modificationData['price'] =
        modificationData['price'].toString().replaceAll('\$', '');
  }

  // Determine the not_installed value.
  // If installedMyself is 1 or installed_by is non-empty, not_installed becomes 0.
  final String notInstalled = (modificationData['installedMyself'] == 1 ||
          (modificationData['installed_by'] != null &&
              modificationData['installed_by'].toString().trim().isNotEmpty))
      ? '0'
      : '1';

  // Build the API URL.
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds/$buildId/modifications/$modificationId';
  final uri = Uri.parse(apiUrl);

  // Use POST with _method override instead of PUT directly.
  final request = http.MultipartRequest('POST', uri);
  request.headers['Accept'] = 'application/json';
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  
  // Override method to PUT.
  request.fields['_method'] = 'PUT';

  // Add text fields from modificationData.
  request.fields['category'] = modificationData['category'] ?? '';
  request.fields['name'] = modificationData['name'] ?? '';
  request.fields['brand'] = modificationData['brand'] ?? '';
  request.fields['price'] = modificationData['price'] ?? '';
  request.fields['part'] = modificationData['part'] ?? '';
  request.fields['notes'] = modificationData['notes'] ?? '';
  request.fields['installed_myself'] = modificationData['installedMyself'].toString();
  request.fields['installed_by'] = modificationData['installed_by'] ?? '';
  // Add the not_installed field.
  request.fields['not_installed'] = notInstalled;

  // Send existing images as a JSON-encoded array.
  request.fields['existing_images'] = json.encode(modificationData['existing_images'] ?? []);

  // Attach new image files, using the key 'images[]' so all files are sent as an array.
  if (newImages != null && newImages.isNotEmpty) {
    for (var img in newImages) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', img.path),
      );
    }
  }

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return true;
    } else {
      String errorMessage = 'Unknown error';
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData.containsKey('errors')) {
          errorMessage = errorData['errors']['name']?[0] ?? errorMessage;
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else {
          errorMessage = response.body;
        }
      } catch (e) {
        errorMessage = response.body;
      }
      _showErrorSnackbar(context, response.statusCode, errorMessage);
      return false;
    }
  } catch (e) {
    _showErrorSnackbar(context, null, e.toString());
    return false;
  }
}

Future<bool> deleteModification({
  required BuildContext context,
  required int buildId,
  required int modificationId,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds/$buildId/modifications/$modificationId';

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      _showErrorSnackbar(context, response.statusCode, response.body);
      return false;
    }
  } catch (e) {
    _showErrorSnackbar(context, null, e.toString());
    return false;
  }
}

void _showErrorSnackbar(
    BuildContext context, int? statusCode, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Error${statusCode != null ? " ($statusCode)" : ""}: $errorMessage',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ),
  );
}
