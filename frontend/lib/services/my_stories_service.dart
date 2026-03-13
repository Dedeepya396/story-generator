import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class StoryService {
  static const String defaultBase = "http://127.0.0.1:8000";

  /// Create a story on the backend.
  /// Returns { success: bool, data?: Map, message?: String }
  static Future<Map<String, dynamic>> createStory({
    required String title,
    String? description,
    String? language,
    String? genre,
    String? videoUrl,
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
      'displayFlag': displayFlag,
    };

    try {
      final base = AuthService.baseUrl.isNotEmpty ? AuthService.baseUrl : defaultBase;
      final uri = Uri.parse('$base/stories/');
      print('StoryService.createStory: POST $uri payload=$payload');
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      print('StoryService.createStory: status=${resp.statusCode} body=${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {'success': true, 'data': body};
      } else {
        final msg = resp.body.isNotEmpty ? resp.body : 'Failed to create story';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Fetch stories for a given user id
  static Future<List<Map<String, dynamic>>> fetchStoriesByUser(String userId) async {
    final token = AuthService.accessToken;
    if (token == null) return [];

    final base = AuthService.baseUrl.isNotEmpty ? AuthService.baseUrl : defaultBase;
    final uri = Uri.parse('$base/stories/user/$userId');

    try {
      print('StoryService.fetchStoriesByUser: GET $uri');
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('StoryService.fetchStoriesByUser: status=${resp.statusCode} body=${resp.body}');
      if (resp.statusCode == 200) {
        final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : [];
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('StoryService.fetchStoriesByUser error: $e');
      return [];
    }
  }

  /// Delete a story permanently by ID
  static Future<Map<String, dynamic>> deleteStory(String storyId) async {
    final token = AuthService.accessToken;
    if (token == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    final base = AuthService.baseUrl.isNotEmpty ? AuthService.baseUrl : defaultBase;
    final uri = Uri.parse('$base/stories/$storyId');

    try {
      print('StoryService.deleteStory: DELETE $uri');
      final resp = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('StoryService.deleteStory: status=${resp.statusCode} body=${resp.body}');
      
      if (resp.statusCode == 200) {
        final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {'success': true, 'data': body};
      } else {
        final msg = resp.body.isNotEmpty ? resp.body : 'Failed to delete story';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      print('StoryService.deleteStory error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}