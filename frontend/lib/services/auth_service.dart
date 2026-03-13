import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static const String baseUrl = "http://127.0.0.1:8000"; 
//   // use your IP if testing on real device
//     static Future<Map<String, dynamic>> login(
//         String email, String password) async {

//     final response = await http.post(
//         Uri.parse("$baseUrl/login"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//         "email": email,
//         "password": password,
//         }),
//     );

//     final data = jsonDecode(response.body);

//     print("Status Code: ${response.statusCode}");
//     print("Response Body: $data");

//     if (response.statusCode == 200 && data["access_token"] != null) {
//         final prefs = await SharedPreferences.getInstance();

//         await prefs.setString("token", data["access_token"]);
//         await prefs.setString("token_type", data["token_type"]);

//         return {"success": true};
//     } else {
//         return {
//         "success": false,
//         "message": data["message"] ?? "Login failed"
//         };
//     }
//     }
// static Future<Map<String, dynamic>> signup(
//     String fullName, String email, String password, String role) async {

//   final response = await http.post(
//     Uri.parse("$baseUrl/signup"),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "fullName": fullName,   // ✅ FIXED
//       "email": email,
//       "password": password,
//       "role": role,           // must be "teacher" or "student"
//     }),
//   );

//   print("Status Code: ${response.statusCode}");
//   print("Body: ${response.body}");

//   final data = jsonDecode(response.body);

//   if (response.statusCode == 200 || response.statusCode == 201) {
//     return {"success": true};
//   } else {
//     return {
//       "success": false,
//       "message": data["detail"] ?? data["message"] ?? "Signup failed"
//     };
//   }
// }}

// ...existing code...
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000";

  // in-memory only
  static String? _accessToken;
  static Map<String, dynamic>? _user;

  static String? get accessToken => _accessToken;
  static Map<String, dynamic>? get user => _user;
  static bool get isLoggedIn => _accessToken != null;

  // login: stores access_token and user in memory and SharedPreferences
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);
    // print("Status Code: ${response.statusCode}");
    // print("Response Body: $data");

    if (response.statusCode == 200 && data["access_token"] != null) {
      _accessToken = data["access_token"];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _accessToken!);

      if (data["user"] is Map) {
        _user = Map<String, dynamic>.from(data["user"]);
      } else {
        _user = {"email": data["email"] ?? email};
      }
      return {"success": true};
    } else {
      return {"success": false, "message": data["message"] ?? data["detail"] ?? "Login failed"};
    }
  }

  // Initialize service by loading token from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("token");
    if (_accessToken != null) {
      await getUserProfile();
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    if (_accessToken == null) return {"success": false, "message": "Not logged in"};

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (response.statusCode == 200) {
      _user = jsonDecode(response.body);
      return {"success": true, "user": _user};
    } else {
      _accessToken = null; // Token might be invalid/expired
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      return {"success": false, "message": "Failed to fetch profile"};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({String? name, String? email, String? password}) async {
    if (_accessToken == null) return {"success": false, "message": "Not logged in"};

    final Map<String, dynamic> body = {};
    if (name != null) body["fullName"] = name;
    if (email != null) body["email"] = email;
    if (password != null) body["password"] = password;

    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      _user = jsonDecode(response.body);
      return {"success": true, "user": _user};
    } else {
      final data = jsonDecode(response.body);
      return {"success": false, "message": data["detail"] ?? data["message"] ?? "Failed to update profile"};
    }
  }

  // signup unchanged (no storage)
  static Future<Map<String, dynamic>> signup(String fullName, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullName": fullName,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    // print("Status Code: ${response.statusCode}");
    // print("Body: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true};
    } else {
      return {"success": false, "message": data["detail"] ?? data["message"] ?? "Signup failed"};
    }
  }

  static void logout() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.setBool('isLoggedIn', false);
  }
}
// ...existing code...