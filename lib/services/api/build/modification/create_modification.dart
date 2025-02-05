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
  String? name,
  String? brand,
  String? price,
  String? part,
  String? notes,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds/$buildId/modifications';

  final Map<String, dynamic> modificationData = {
    'category': category,
    'name': name,
    'brand': brand,
    'price': price,
    'part': part,
    'notes': notes,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(modificationData),
    );

    if (response.statusCode == 201) {
      // Modification added successfully.
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
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
