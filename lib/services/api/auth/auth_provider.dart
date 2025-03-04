import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pd/services/api/auth/auth_exception.dart';

class ApiAuthProvider {
  final String baseUrl;
  String? _token;

  ApiAuthProvider({required this.baseUrl});

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<String?> getToken() async {
    await _loadToken();
    return _token;
  }

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': displayName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      throw ApiException(
        message: responseData['message'] ?? 'Registration failed',
        code: responseData['code'] ?? 'registration_failed',
      );
    }
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'] as String;
      await _saveToken(token);
    } else {
      final responseData = jsonDecode(response.body);
      final code = responseData['code'] as String?;
      if (code == 'user_not_found') {
        throw UserNotFoundException();
      } else if (code == 'invalid_credentials') {
        throw InvalidCredentialsException();
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Login failed',
          code: responseData['code'] ?? 'login_failed',
        );
      }
    }
  }

  Future<void> logOut() async {
    if (_token == null) return;

    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      await _removeToken();
    } else {
      throw ApiException(
        message: 'Logout failed',
        code: 'logout_failed',
      );
    }
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<AuthUser?> getCurrentUser() async {
    await _loadToken();
    if (_token == null) return null;

    final url = Uri.parse('$baseUrl/user');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthUser.fromJson(data);
    } else {
      return null;
    }
  }

  Future<void> sendEmailVerification() async {
    final user = await getCurrentUser();
    if (user == null) throw Exception("User not found");

    final url = Uri.parse('$baseUrl/email/resend');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': user.email}),
    );

    if (response.statusCode != 200) {
      final responseData = jsonDecode(response.body);
      throw ApiException(
        message: responseData['message'] ?? 'Failed to send email verification',
        code: responseData['code'] ?? 'email_verification_failed',
      );
    }
  }

  Future<void> sendPasswordReset({required String toEmail}) async {
    final url = Uri.parse('$baseUrl/password-reset');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': toEmail}),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final responseData = jsonDecode(response.body);
      throw ApiException(
        message: responseData['message'] ?? 'Password reset failed',
        code: responseData['code'] ?? 'password_reset_failed',
      );
    }
  }

  Future<void> initialize() async {
    await _loadToken();
  }
}
