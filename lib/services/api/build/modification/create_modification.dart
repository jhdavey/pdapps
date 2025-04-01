// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth/auth_service.dart';

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
  List? images,
  required int notInstalled,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();

  if (price != null) {
    price = price.replaceAll('\$', '');
  }

  final String apiUrl =
      'https://passiondrivenbuilds.com/api/builds/$buildId/modifications';

  final uri = Uri.parse(apiUrl);
  final request = http.MultipartRequest('POST', uri);

  request.headers['Accept'] = 'application/json';
  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  // Add text fields.
  request.fields['category'] = category;
  if (name != null) request.fields['name'] = name;
  if (brand != null) request.fields['brand'] = brand;
  if (price != null) request.fields['price'] = price;
  if (part != null) request.fields['part'] = part;
  if (notes != null) request.fields['notes'] = notes;
  request.fields['installed_myself'] = installedMyself.toString();
  request.fields['installed_by'] = installedMyself == 1 ? "" : (installedBy ?? "");
  // Send the not_installed field.
  request.fields['not_installed'] = notInstalled.toString();

  // Add image files if provided, using the key 'images[]'
  if (images != null && images.isNotEmpty) {
    for (var img in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', img.path),
      );
    }
  }

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    return false;
  }
}
