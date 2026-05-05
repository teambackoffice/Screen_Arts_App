import 'package:flutter/material.dart';
import 'package:screen_arts_app/modal/job_work_modal_class.dart';
import 'package:screen_arts_app/service/job_order_service.dart';

class JobWorkController extends ChangeNotifier {
  final JobWorkService _service = JobWorkService();

  bool isLoading = false;
  JobWorkModalClass? jobWorks;
  String? error;

  Future<void> getJobWorks() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _service.fetchJobWorks();

      if (result != null) {
        jobWorks = result;
      } else {
        error = "No data found";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
