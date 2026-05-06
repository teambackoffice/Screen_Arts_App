import 'package:flutter/material.dart';
import 'package:screen_arts_app/service/check_in_out_service.dart';

class CheckinController extends ChangeNotifier {
  final CheckinService _service = CheckinService();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> markCheckin(String logType) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final response = await _service.markCheckin(logType: logType);

      final msg = response["message"];
      if (msg is Map) {
        successMessage = msg["message"]?.toString() ?? "Success";
      } else {
        successMessage = msg?.toString() ?? "Success";
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
