// api_auth_service.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/auth/auth_user.dart';
import 'package:pd/services/api/auth/auth_provider.dart';

class ApiAuthService {
  final ApiAuthProvider _apiAuthProvider;

  ApiAuthService(this._apiAuthProvider);

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await _apiAuthProvider.register(
      displayName: displayName,
      email: email,
      password: password,
    );
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    await _apiAuthProvider.logIn(email: email, password: password);
  }

  Future<void> logOut([BuildContext? context]) async {
    try {
      await _apiAuthProvider.logOut();
    } catch (e) {
      debugPrint('Logout API failed: $e');
    } finally {
      await _apiAuthProvider.clearAuthData();
      if (context != null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    return await _apiAuthProvider.getCurrentUser();
  }

  Future<void> sendEmailVerification() async {
    await _apiAuthProvider.sendEmailVerification();
  }

  Future<void> sendPasswordReset({required String toEmail}) async {
    await _apiAuthProvider.sendPasswordReset(toEmail: toEmail);
  }

  Future<void> initialize() async {
    await _apiAuthProvider.initialize();
  }

  Future<String?> getToken() async {
    return await _apiAuthProvider.getToken();
  }
}
