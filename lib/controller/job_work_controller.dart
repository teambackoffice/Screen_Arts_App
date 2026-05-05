import 'package:flutter/material.dart';
import 'package:screen_arts_app/service/job_work_service.dart';
import 'package:screen_arts_app/modal/job_work_modal_class.dart';

enum JobWorkStatus { idle, running, stopped, completed }

/// Holds a single start/stop entry created locally in this session
class LocalTimeEntry {
  final DateTime startTime;
  DateTime? stopTime;
  LocalTimeEntry({required this.startTime, this.stopTime});
}

class JobWorkProvider extends ChangeNotifier {
  final JobWorkService _service = JobWorkService();

  // ─── State ────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  JobWorkStatus _status = JobWorkStatus.idle;
  String _errorMessage = '';
  String _successMessage = '';
  String _currentJobWorkName = '';
  final List<LocalTimeEntry> _localTimeLogs = [];
  Message? _job;

  // ─── Getters ──────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  JobWorkStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String get currentJobWorkName => _currentJobWorkName;

  /// Returns local time log entries in reverse order (newest first)
  List<LocalTimeEntry> get localTimeLogs =>
      List.unmodifiable(_localTimeLogs.reversed.toList());

  // ─── Init ─────────────────────────────────────────────────────────────────

  void init(Message job) {
    _job = job;
    _currentJobWorkName = job.name;
    
    if (job.status == 'Completed' || job.customJobStatus == 'Completed') {
      _status = JobWorkStatus.completed;
      return;
    }

    bool isRunning = job.timeLogs.any((log) => log.fromTime != null && log.toTime == null);
    
    if (isRunning) {
      _status = JobWorkStatus.running;
    } else if (job.timeLogs.any((log) => log.fromTime != null && log.toTime != null)) {
      _status = JobWorkStatus.stopped;
    } else if (job.customJobStatus == 'In Progress') {
      // Fallback just in case
      _status = JobWorkStatus.running; 
    } else if (job.customJobStatus == 'Stopped') {
      _status = JobWorkStatus.stopped;
    } else {
      _status = JobWorkStatus.idle;
    }
  }

  // ─── Start ────────────────────────────────────────────────────────────────

  Future<void> startTimeLog(String jobWorkName) async {
    await _execute(
      action: () => _service.startTimeLog(jobWorkName),
      jobWorkName: jobWorkName,
      successStatus: JobWorkStatus.running,
      successMsg: 'Time log started',
      onSuccess: () {
        _localTimeLogs.add(LocalTimeEntry(startTime: DateTime.now()));
      },
    );
  }

  // ─── Stop ─────────────────────────────────────────────────────────────────

  Future<void> stopTimeLog(String jobWorkName) async {
    await _execute(
      action: () => _service.stopTimeLog(jobWorkName),
      jobWorkName: jobWorkName,
      successStatus: JobWorkStatus.stopped,
      successMsg: 'Time log stopped',
      onSuccess: () {
        // Close the most recent open entry
        bool closedLocal = false;
        for (int i = _localTimeLogs.length - 1; i >= 0; i--) {
          if (_localTimeLogs[i].stopTime == null) {
            _localTimeLogs[i].stopTime = DateTime.now();
            closedLocal = true;
            break;
          }
        }
        if (!closedLocal && _job != null) {
          for (var log in _job!.timeLogs) {
            if (log.toTime == null) {
              log.toTime = DateTime.now();
            }
          }
        }
      },
    );
  }

  // ─── Continue ─────────────────────────────────────────────────────────────

  Future<void> continueTimeLog(String jobWorkName) async {
    await _execute(
      action: () => _service.continueTimeLog(jobWorkName),
      jobWorkName: jobWorkName,
      successStatus: JobWorkStatus.running,
      successMsg: 'Time log resumed',
      onSuccess: () {
        // Continue = new time segment
        _localTimeLogs.add(LocalTimeEntry(startTime: DateTime.now()));
      },
    );
  }

  // ─── Complete ─────────────────────────────────────────────────────────────

  Future<void> completeJobWork(String jobWorkName) async {
    await _execute(
      action: () => _service.completeJobWork(jobWorkName),
      jobWorkName: jobWorkName,
      successStatus: JobWorkStatus.completed,
      successMsg: 'Job completed successfully',
      onSuccess: () {
        // Close any open entry
        for (final e in _localTimeLogs) {
          e.stopTime ??= DateTime.now();
        }
        if (_job != null) {
          for (var log in _job!.timeLogs) {
            if (log.toTime == null) {
              log.toTime = DateTime.now();
            }
          }
        }
      },
    );
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void reset() {
    _isLoading = false;
    _status = JobWorkStatus.idle;
    _errorMessage = '';
    _successMessage = '';
    _currentJobWorkName = '';
    _localTimeLogs.clear();
    notifyListeners();
  }

  // ─── Private helper ───────────────────────────────────────────────────────

  Future<void> _execute({
    required Future<Map<String, dynamic>> Function() action,
    required String jobWorkName,
    required JobWorkStatus successStatus,
    required String successMsg,
    VoidCallback? onSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      await action();
      _currentJobWorkName = jobWorkName;
      _status = successStatus;
      _successMessage = successMsg;
      onSuccess?.call();
    } on ApiException catch (e) {
      _errorMessage = 'Error ${e.statusCode}: ${e.message}';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
