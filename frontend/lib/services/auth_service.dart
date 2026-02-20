import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000"; 
  // use your IP if testing on real device
    static Future<Map<String, dynamic>> login(
        String email, String password) async {

    final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
        "email": email,
        "password": password,
        }),
    );

    final data = jsonDecode(response.body);

    print("Status Code: ${response.statusCode}");
    print("Response Body: $data");

    if (response.statusCode == 200 && data["access_token"] != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", data["access_token"]);
        await prefs.setString("token_type", data["token_type"]);

        return {"success": true};
    } else {
        return {
        "success": false,
        "message": data["message"] ?? "Login failed"
        };
    }
    }
static Future<Map<String, dynamic>> signup(
    String fullName, String email, String password, String role) async {

  final response = await http.post(
    Uri.parse("$baseUrl/signup"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "fullName": fullName,   // ✅ FIXED
      "email": email,
      "password": password,
      "role": role,           // must be "teacher" or "student"
    }),
  );

  print("Status Code: ${response.statusCode}");
  print("Body: ${response.body}");

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return {"success": true};
  } else {
    return {
      "success": false,
      "message": data["detail"] ?? data["message"] ?? "Signup failed"
    };
  }
}}