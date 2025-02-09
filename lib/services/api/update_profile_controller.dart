// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:http_parser/http_parser.dart';

Future<bool> updateProfile({
  required BuildContext context,
  required String name,
  required String email,
  required String bio,
  required String instagram,
  required String facebook,
  required String tiktok,
  required String youtube,
  File? profileImage,
}) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/profile';

  var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
    ..headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    })
    ..fields['name'] = name.toString()
    ..fields['email'] = email.toString()
    ..fields['bio'] = bio.toString()
    ..fields['instagram'] = instagram.toString()
    ..fields['facebook'] = facebook.toString()
    ..fields['tiktok'] = tiktok.toString()
    ..fields['youtube'] = youtube.toString()
    ..fields['_method'] = 'PUT';

  if (profileImage != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'profile_image',
      profileImage.path,
      contentType: MediaType('image', 'jpeg'),
    ));
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    debugPrint("Response: $responseBody");

    if (response.statusCode == 200) {
      return true;
    } else {
      _showErrorSnackbar(context, response.statusCode, responseBody);
      return false;
    }
  } catch (e) {
    _showErrorSnackbar(context, null, e.toString());
    return false;
  }
}

Future<bool> deleteProfile(BuildContext context) async {
  final authService = RepositoryProvider.of<ApiAuthService>(context);
  final token = await authService.getToken();
  final String apiUrl = 'https://passiondrivenbuilds.com/api/profile';

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await authService.logOut(context);
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
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
        'Error ${statusCode != null ? "($statusCode)" : ""}: $errorMessage',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ),
  );
}
