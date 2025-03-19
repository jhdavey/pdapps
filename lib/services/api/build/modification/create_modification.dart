// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:http/http.dart' as http;

Future<bool> submitModification(
  BuildContext context,
  String buildId, {
  required String category,
  required String? name,
  String? brand,
  String? price,
  String? part,
  String? notes,
  required int installedMyself,
  String? installedBy,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  // Remove any dollar sign from price.
  if (price != null) {
    price = price.replaceAll('\$', '');
  }

  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds/$buildId/modifications';

  final Map<String, dynamic> modificationData = {
    'category': category,
    'name': name,
    'brand': brand,
    'price': price,
    'part': part,
    'notes': notes,
    'installed_myself': installedMyself,
    'installed_by': installedMyself == 1 ? "" : installedBy,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(modificationData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      String errorMessage = 'Unknown error';
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData.containsKey('errors')) {
          errorMessage = errorData['errors']['name']?.first ?? errorMessage;
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else {
          errorMessage = response.body;
        }
      } catch (e) {
        errorMessage = response.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
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

