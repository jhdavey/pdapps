import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BuildImageCaptionController {
  final String baseUrl;

  BuildImageCaptionController.buildImageCaptionController(
      {required this.baseUrl});

  Future<bool> updateCaption({
    required int buildImageId,
    required String caption,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return false;
    }

    final Uri url =
        Uri.parse('$baseUrl/api/build-images/$buildImageId/caption');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'caption': caption}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
