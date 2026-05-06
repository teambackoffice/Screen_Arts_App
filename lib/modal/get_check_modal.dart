class CheckinStatusModel {
  final String status;
  final String employee;
  final String logType;
  final String time;

  CheckinStatusModel({
    required this.status,
    required this.employee,
    required this.logType,
    required this.time,
  });

  factory CheckinStatusModel.fromJson(Map<String, dynamic> json) {
    return CheckinStatusModel(
      status: json['status'] ?? '',
      employee: json['employee'] ?? '',
      logType: json['log_type'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
