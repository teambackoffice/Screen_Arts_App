import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen_arts_app/config/api_constant.dart';
import 'package:screen_arts_app/modal/job_work_modal_class.dart';

class JobWorkService {
  static const String _url =
      '${ApiConstants.baseUrl}api/method/screenarts.screenarts.doctype.job_work.job_work.get_user_assigned_job_works';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getSid() async {
    return await _storage.read(key: 'sid');
  }

  Future<JobWorkModalClass?> fetchJobWorks() async {
    try {
      final sid = await _getSid();

      if (sid == null) {
        throw Exception("SID token not found in storage");
      }

      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Authorization': 'token $sid',
          'Cookie': "sid=$sid",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return JobWorkModalClass.fromJson(data);
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }
}
