import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pd/services/auth/auth_user.dart';
import 'package:pd/services/auth/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pd/services/api/auth_exception.dart';

class ApiAuthProvider implements AuthProvider {
  final String baseUrl;
  String? _token;

  ApiAuthProvider({required this.baseUrl});

  // Load token from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  // Remove token from SharedPreferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  @override
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

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Registration successful
      // Optionally, you can auto-login the user here
    } else {
      throw ApiException(
        message: responseData['message'] ?? 'Registration failed',
        code: responseData['code'] ?? 'registration_failed',
      );
    }
  }

  @override
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

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = responseData['token'] as String;
      await _saveToken(token);
    } else {
      throw ApiException(
        message: responseData['message'] ?? 'Login failed',
        code: responseData['code'] ?? 'login_failed',
      );
    }
  }

  @override
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

  @override
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

  @override
  Future<void> sendEmailVerification() async {
    if (_token == null) throw ApiException(message: 'User not logged in', code: 'not_logged_in');

    final url = Uri.parse('$baseUrl/send-email-verification');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ApiException(
        message: responseData['message'] ?? 'Failed to send email verification',
        code: responseData['code'] ?? 'email_verification_failed',
      );
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    final url = Uri.parse('$baseUrl/password-reset');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': toEmail}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ApiException(
        message: responseData['message'] ?? 'Password reset failed',
        code: responseData['code'] ?? 'password_reset_failed',
      );
    }
  }

  @override
  Future<void> initialize() async {
    await _loadToken();
  }
}
