import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen_arts_app/modal/get_check_modal.dart';

class GetCheckinStatusService {
  static const String _url =
      'https://uat-screenarts.tbo365.cloud/api/method/screenarts.api.get_employee_checkin_status';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getSid() async {
    return await _storage.read(key: 'sid');
  }

  Future<CheckinStatusModel> getCheckinStatus() async {
    try {
      final sid = await _getSid();

      if (sid == null) {
        throw Exception("Session expired. Please login again.");
      }

      print(" ========== GET CHECK REQUEST ==========");
      print("URL: $_url");
      print("HEADERS: {'Authorization': 'token $sid'}");

      final response = await http.get(
        Uri.parse(_url),
        headers: {'Authorization': 'token $sid', 'Cookie': 'sid=$sid'},
      );

      print(" ========== GET CHECK RESPONSE ==========");
      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CheckinStatusModel.fromJson(data["message"]);
      } else {
        throw Exception(data["message"] ?? "Failed to fetch status");
      }
    } catch (e) {
      print(" ========== GET CHECK ERROR ==========");
      print(e.toString());
      throw Exception("Error: $e");
    }
  }
}
