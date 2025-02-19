import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdditionalMediaController {
  final String baseUrl;
  AdditionalMediaController({required this.baseUrl});

  /// Upload one or more additional media files to an existing build.
  Future<List<Map<String, dynamic>>> uploadAdditionalMedia({
    required int buildId,
    required List<File> files,
  }) async {
    final uri = Uri.parse('$baseUrl/api/builds/$buildId/media');
    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Attach each file under the key "additional_media[]" so Laravel treats it as an array.
    for (final file in files) {
      // Using fromPath automatically sets the content type based on the file extension.
      final multipartFile = await http.MultipartFile.fromPath(
        'additional_media[]',
        file.path,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Debug logging: print status code and response body.
    print("Upload additional media response status: ${response.statusCode}");
    print("Upload additional media response body: ${response.body}");

    if (response.statusCode == 201) {
      // Assuming the server returns the updated media list in a "data" field.
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to upload additional media');
    }
  }

  /// Delete an additional media item by its ID.
  Future<bool> deleteAdditionalMedia({required int mediaId}) async {
    final uri = Uri.parse('$baseUrl/api/build-images/$mediaId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.delete(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200;
  }
}
