import 'dart:convert';
import 'package:http/http.dart' as http;

class AIStoryService {

  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<String?> generateStory(String message) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/story/generate_story"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        return data["story"];

      } else {

        print("AI API Error: ${response.body}");
        return null;

      }

    } catch (e) {

      print("AI Service Exception: $e");
      return null;

    }

  }
}