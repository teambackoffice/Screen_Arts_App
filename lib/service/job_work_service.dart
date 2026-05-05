import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JobWorkService {
  static const String _baseUrl =
      'https://uat-screenarts.tbo365.cloud/api/method/screenarts.screenarts.doctype.job_work.job_work';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Retrieves the session ID (sid) from Flutter Secure Storage
  Future<String?> _getSid() async {
    return await _secureStorage.read(key: 'sid');
  }

  /// Builds authorization headers using sid from secure storage
  Future<Map<String, String>> _buildHeaders() async {
    final sid = await _getSid();
    if (sid == null || sid.isEmpty) {
      throw Exception('Session ID (sid) not found. Please log in again.');
    }
    return {
      'Authorization': 'token $sid',
      'Content-Type': 'application/json',
      "Cookie": "sid=$sid",
    };
  }

  /// Generic POST method for all job work actions
  Future<Map<String, dynamic>> _post(
    String endpoint,
    String jobWorkName,
  ) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$_baseUrl.$endpoint');

    final request = http.Request('POST', uri);
    request.headers.addAll(headers);
    request.body = json.encode({'job_work_name': jobWorkName});

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      try {
        final decoded = json.decode(responseBody);
        return decoded as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON response');
      }
    } else {
      throw ApiException(
        statusCode: streamedResponse.statusCode,
        message: streamedResponse.reasonPhrase ?? 'Unknown error',
        body: responseBody,
      );
    }
  }

  /// Starts the time log for a job work
  Future<Map<String, dynamic>> startTimeLog(String jobWorkName) async {
    return _post('start_time_log', jobWorkName);
  }

  /// Stops the time log for a job work
  Future<Map<String, dynamic>> stopTimeLog(String jobWorkName) async {
    return _post('stop_time_log', jobWorkName);
  }

  /// Continues (resumes) the time log for a job work
  Future<Map<String, dynamic>> continueTimeLog(String jobWorkName) async {
    return _post('continue_time_log', jobWorkName);
  }

  /// Marks a job work as complete
  Future<Map<String, dynamic>> completeJobWork(String jobWorkName) async {
    return _post('complete_job_work_server', jobWorkName);
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String body;

  const ApiException({
    required this.statusCode,
    required this.message,
    required this.body,
  });

  @override
  String toString() => 'ApiException[$statusCode]: $message\nBody: $body';
}
