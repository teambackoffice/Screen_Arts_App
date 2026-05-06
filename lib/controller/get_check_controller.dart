import 'package:flutter/material.dart';
import 'package:screen_arts_app/service/get_check_service.dart';
import 'package:screen_arts_app/modal/get_check_modal.dart';

class CheckinStatusController extends ChangeNotifier {
  final GetCheckinStatusService _service = GetCheckinStatusService();

  bool isLoading = false;
  String? errorMessage;
  CheckinStatusModel? statusData;

  Future<void> fetchStatus() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      statusData = await _service.getCheckinStatus();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
