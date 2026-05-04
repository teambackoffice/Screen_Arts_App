import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:screen_arts_app/config/api_constant.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ─── Storage Keys ────────────────────────────────────────────────────────────
  static const String _keySid = 'sid';
  static const String _keyFullName = 'full_name';
  static const String _keyEmployeeId = 'employee_id';

  // ─── Login ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}api/method/screenarts.api.custom_login',
    );

    final requestBody = {"usr": username, "pwd": password};

    print("🔵 REQUEST URL: $uri");
    print("🔵 REQUEST BODY: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("🟢 STATUS CODE: ${response.statusCode}");
      print("🟢 RESPONSE BODY: ${response.body}");

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Extract nested message object
        final message = data['message'] as Map<String, dynamic>?;

        final sid = message?['sid'] as String?;
        final fullName =
            (message?['full_name'] ?? data['full_name']) as String?;
        final employeeId = message?['employee_id'] as String?;

        // Persist to secure storage
        if (sid != null) await _storage.write(key: _keySid, value: sid);
        if (fullName != null) {
          await _storage.write(key: _keyFullName, value: fullName);
        }
        if (employeeId != null) {
          await _storage.write(key: _keyEmployeeId, value: employeeId);
        }

        print(
          "✅ Session saved — sid: $sid | employee: $employeeId | name: $fullName",
        );

        return data;
      } else {
        throw Exception("Login failed: ${data.toString()}");
      }
    } catch (e) {
      print("🔴 ERROR: $e");
      rethrow;
    }
  }

  // ─── Load persisted session ──────────────────────────────────────────────────
  Future<Map<String, String?>> loadSession() async {
    return {
      _keySid: await _storage.read(key: _keySid),
      _keyFullName: await _storage.read(key: _keyFullName),
      _keyEmployeeId: await _storage.read(key: _keyEmployeeId),
    };
  }

  // ─── Clear session (logout) ──────────────────────────────────────────────────
  Future<void> clearSession() async {
    await _storage.delete(key: _keySid);
    await _storage.delete(key: _keyFullName);
    await _storage.delete(key: _keyEmployeeId);
    print("🔴 Session cleared");
  }
}
