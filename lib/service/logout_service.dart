import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen_arts_app/config/api_constant.dart';

class LogoutService {
  static const String _url =
      '${ApiConstants.baseUrl}api/method/screenarts.api.custom_logout';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getSid() async {
    return await _storage.read(key: 'sid');
  }

  Future<Map<String, dynamic>> logout({required String username}) async {
    final sid = await _getSid();

    if (sid == null) {
      throw Exception("Session expired. Please login again.");
    }

    print("🔴 LOGOUT REQUEST:");
    print("URL: $_url");
    print("SID: $sid");

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid', // ✅ Frappe reads SID as a cookie
        'X-Frappe-CSRF-Token': 'fetch', // ✅ Required for POST in Frappe
      },
      body: json.encode({"usr": username}),
    );

    print("🟢 RESPONSE:");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Logout failed: ${response.reasonPhrase}");
    }
  }
}
