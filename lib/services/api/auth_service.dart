// api_auth_service.dart
import 'package:pd/services/api/auth_user.dart';
import 'package:pd/services/api/auth_provider.dart';

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

  Future<void> logOut() async {
    await _apiAuthProvider.logOut();
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

  // Add this method to expose the token from the underlying provider.
  Future<String?> getToken() async {
    return await _apiAuthProvider.getToken();
  }
}
