import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen_arts_app/config/api_constant.dart';

class CheckinService {
  static const String _baseUrl =
      '${ApiConstants.baseUrl}api/method/screenarts.api.mark_employee_checkin';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getSid() async {
    return await _storage.read(key: 'sid');
  }

  Future<Map<String, dynamic>> markCheckin({required String logType}) async {
    try {
      final sid = await _getSid();

      if (sid == null) {
        throw Exception("Session expired. Please login again.");
      }

      final url = Uri.parse(_baseUrl);

      final headers = {
        'Authorization': 'token $sid',
        'Content-Type': 'application/json',
        "Cookie": "sid=$sid",
      };

      final body = jsonEncode({"log_type": logType});

      // 🔹 PRINT REQUEST
      print("=========== CHECKIN API REQUEST ===========");
      print("URL: $url");
      print("HEADERS: $headers");
      print("BODY: $body");

      final response = await http.post(url, headers: headers, body: body);

      // 🔹 PRINT RESPONSE
      print("=========== CHECKIN API RESPONSE ===========");
      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("PARSED RESPONSE: $data");
        return data;
      } else {
        print("ERROR RESPONSE: $data");
        throw Exception(data["message"] ?? "Something went wrong");
      }
    } catch (e) {
      print("=========== CHECKIN ERROR ===========");
      print(e.toString());
      throw Exception("Check-in failed: $e");
    }
  }
}
