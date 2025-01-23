import 'auth_user.dart';

abstract class AuthProvider {
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> logIn({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<AuthUser?> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordReset({required String toEmail});

  Future<void> initialize();
}
