// ...existing code...
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class StoryService {
  /// Create a story document on the backend.
  /// Requires user to be logged in (AuthService.user + AuthService.accessToken).
  static Future<Map<String, dynamic>> createStory({
    required String title,
    String? description,
    String? language,
    String? genre,
    String? videoUrl,
    String? coverUrl,
    String? subtitleUrl,
    required bool displayFlag,
  }) async {
    final user = AuthService.user;
    final token = AuthService.accessToken;
    if (user == null || token == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    final userId = user['id'] ?? user['_id'] ?? user['user_id'];
    if (userId == null) {
      return {'success': false, 'message': 'User id not available'};
    }

    final payload = {
      'userId': userId,
      'title': title,
      'description': description,
      'language': language,
      'genre': genre,
      'videoUrl': videoUrl,
      'coverUrl': coverUrl,
      'subtitleUrl': subtitleUrl,
      'displayFlag': displayFlag,
    };

    try {
      // use AuthService.baseUrl if available, else fallback
      final base = (AuthService.baseUrl != null) ? AuthService.baseUrl : 'http://127.0.0.1:8000';
      final uri = Uri.parse('$base/stories/');
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = resp.bodyBytes.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'message': resp.body.isNotEmpty ? resp.body : 'Failed to create story'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
// ...existing code...