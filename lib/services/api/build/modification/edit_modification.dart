// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<bool> updateModification({
  required BuildContext context,
  required int buildId,
  required int modificationId,
  required Map<String, dynamic> modificationData,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  
  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds/$buildId/modifications/$modificationId';
  
  if (modificationData['price'] != null) {
    modificationData['price'] = modificationData['price']
        .toString()
        .replaceAll('\$', '');
  }
  
  modificationData = {
    'category': modificationData['category'],
    'name': modificationData['name'],
    'brand': modificationData['brand'],
    'price': modificationData['price'],
    'part': modificationData['part'],
    'notes': modificationData['notes'],
    'installed_myself': modificationData['installedMyself'],
    'installed_by': modificationData['installed_by'],
  };

  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Expect JSON responses.
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(modificationData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Try to parse and extract a human-friendly error message.
      String errorMessage = 'Unknown error';
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData.containsKey('errors')) {
          // For example, if the "name" field is required.
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

void _showErrorSnackbar(BuildContext context, int? statusCode, String errorMessage) {
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
