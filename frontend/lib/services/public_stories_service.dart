// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'auth_service.dart';

// class PublicStoriesService {
//   static const String defaultBase = "http://127.0.0.1:8000";

//   /// Fetch all public stories (backend should expose /stories/public)
//   static Future<List<Map<String, dynamic>>> fetchPublicStories() async {
//     final base = (AuthService.baseUrl != null && AuthService.baseUrl!.isNotEmpty)
//         ? AuthService.baseUrl!
//         : defaultBase;
//     final uri = Uri.parse('$base/stories/public');
//     print('Fetching public stories from $uri');
//     try {
//       final resp = await http.get(uri, headers: {
//         'Content-Type': 'application/json',
//       });

//       if (resp.statusCode == 200 && resp.body.isNotEmpty) {
//         final body = jsonDecode(resp.body);
//         if (body is List) return List<Map<String, dynamic>>.from(body);
//       }
//       return [];
//     } catch (e) {
//       print('PublicStoriesService.fetchPublicStories error: $e');
//       return [];
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PublicStoriesService {
  static const String defaultBase = "http://127.0.0.1:8000";

  static Future<List<Map<String, dynamic>>> fetchPublicStories() async {
    final baseRaw = (AuthService.baseUrl != null && AuthService.baseUrl!.isNotEmpty)
        ? AuthService.baseUrl!
        : defaultBase;

    final base = baseRaw.replaceAll(RegExp(r'/+$'), ''); // remove trailing slashes
    final uri = Uri.parse('$base/stories/public');

    // debug log
    print('PublicStoriesService.fetchPublicStories: base="$base" uri="$uri"');

    try {
      final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});
      print('PublicStoriesService.fetchPublicStories: status=${resp.statusCode} body=${resp.body}');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final body = jsonDecode(resp.body);
        if (body is List) return List<Map<String, dynamic>>.from(body);
      }
      return [];
    } catch (e) {
      print('PublicStoriesService.fetchPublicStories error: $e');
      return [];
    }
  }
}