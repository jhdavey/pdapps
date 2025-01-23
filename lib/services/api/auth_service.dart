// lib/services/api/auth_service.dart

import 'package:pd/services/auth/auth_provider.dart';
import 'package:pd/services/auth/auth_user.dart';
import 'package:pd/services/api/auth_provider.dart';

class ApiAuthService implements AuthProvider {
  final ApiAuthProvider _apiAuthProvider;

  ApiAuthService(this._apiAuthProvider);

  @override
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

  @override
  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    await _apiAuthProvider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() async {
    await _apiAuthProvider.logOut();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return await _apiAuthProvider.getCurrentUser();
  }

  @override
  Future<void> sendEmailVerification() async {
    await _apiAuthProvider.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    await _apiAuthProvider.sendPasswordReset(toEmail: toEmail);
  }

  @override
  Future<void> initialize() async {
    await _apiAuthProvider.initialize();
  }
}
