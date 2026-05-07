// To parse this JSON data, do
//
//     final jobWorkModalClass = jobWorkModalClassFromJson(jsonString);

import 'dart:convert';

JobWorkModalClass jobWorkModalClassFromJson(String str) =>
    JobWorkModalClass.fromJson(json.decode(str));

String jobWorkModalClassToJson(JobWorkModalClass data) =>
    json.encode(data.toJson());

class JobWorkModalClass {
  List<Message> message;

  JobWorkModalClass({required this.message});

  factory JobWorkModalClass.fromJson(Map<String, dynamic> json) =>
      JobWorkModalClass(
        message: List<Message>.from(
          json["message"].map((x) => Message.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
  };
}

class Message {
  String name;
  String owner;
  DateTime creation;
  DateTime modified;
  String modifiedBy;
  double docstatus;
  double idx;
  String namingSeries;
  String jobOrder;
  String customSalesOrderNumber;
  dynamic productionItem;
  dynamic employee;
  dynamic customDesigner;
  dynamic customPrintingPerson;
  dynamic customFinishingPerson;
  String operation;
  DateTime postingDate;
  String company;
  String customer;
  String customCustomerName;
  String status;
  String customJobStatus;
  String customServiceType;
  dynamic customDesignFile;
  dynamic expectedStartDate;
  double expectedTimeRequiredInMins;
  dynamic expectedEndDate;
  dynamic actualStartDate;
  double totalTimeInMins;
  dynamic actualEndDate;
  dynamic amendedFrom;
  String doctype;
  List<dynamic> customPrintItems;
  List<TimeLog> timeLogs;
  List<CustomEmployee> customEmployees;
  List<CustomItem> customItems;
  List<dynamic> scheduledTimeLogs;

  Message({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    required this.namingSeries,
    required this.jobOrder,
    required this.customSalesOrderNumber,
    required this.productionItem,
    required this.employee,
    required this.customDesigner,
    required this.customPrintingPerson,
    required this.customFinishingPerson,
    required this.operation,
    required this.postingDate,
    required this.company,
    required this.customer,
    required this.customCustomerName,
    required this.status,
    required this.customJobStatus,
    required this.customServiceType,
    required this.customDesignFile,
    required this.expectedStartDate,
    required this.expectedTimeRequiredInMins,
    required this.expectedEndDate,
    required this.actualStartDate,
    required this.totalTimeInMins,
    required this.actualEndDate,
    required this.amendedFrom,
    required this.doctype,
    required this.customPrintItems,
    required this.timeLogs,
    required this.customEmployees,
    required this.customItems,
    required this.scheduledTimeLogs,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    name: json["name"] ?? "",
    owner: json["owner"] ?? "",
    creation: DateTime.parse(json["creation"]),
    modified: DateTime.parse(json["modified"]),
    modifiedBy: json["modified_by"] ?? "",
    docstatus: json["docstatus"]?.toDouble() ?? 0.0,
    idx: json["idx"]?.toDouble() ?? 0.0,
    namingSeries: json["naming_series"] ?? "",
    jobOrder: json["job_order"] ?? "",
    customSalesOrderNumber: json["custom_sales_order_number"] ?? "",
    productionItem: json["production_item"],
    employee: json["employee"],
    customDesigner: json["custom_designer"],
    customPrintingPerson: json["custom_printing_person"],
    customFinishingPerson: json["custom_finishing_person"],
    operation: json["operation"] ?? "",
    postingDate: DateTime.parse(json["posting_date"]),
    company: json["company"] ?? "",
    customer: json["customer"] ?? "",
    customCustomerName: json["custom_customer_name"] ?? "",
    status: json["status"] ?? "",
    customJobStatus: json["custom_job_status"] ?? "",
    customServiceType: json["custom_service_type"] ?? "",
    customDesignFile: json["custom_design_file"],
    expectedStartDate: json["expected_start_date"],
    expectedTimeRequiredInMins: json["expected_time_required_in_mins"]?.toDouble() ?? 0.0,
    expectedEndDate: json["expected_end_date"],
    actualStartDate: json["actual_start_date"],
    totalTimeInMins: json["total_time_in_mins"]?.toDouble() ?? 0.0,
    actualEndDate: json["actual_end_date"],
    amendedFrom: json["amended_from"],
    doctype: json["doctype"] ?? "",
    customPrintItems: json["custom_print_items"] != null ? List<dynamic>.from(
      json["custom_print_items"].map((x) => x),
    ) : [],
    timeLogs: json["time_logs"] != null ? List<TimeLog>.from(
      json["time_logs"].map((x) => TimeLog.fromJson(x)),
    ) : [],
    customEmployees: json["custom_employees"] != null ? List<CustomEmployee>.from(
      json["custom_employees"].map((x) => CustomEmployee.fromJson(x)),
    ) : [],
    customItems: json["custom_items"] != null ? List<CustomItem>.from(
      json["custom_items"].map((x) => CustomItem.fromJson(x)),
    ) : [],
    scheduledTimeLogs: json["scheduled_time_logs"] != null ? List<dynamic>.from(
      json["scheduled_time_logs"].map((x) => x),
    ) : [],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation.toIso8601String(),
    "modified": modified.toIso8601String(),
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "naming_series": namingSeries,
    "job_order": jobOrder,
    "custom_sales_order_number": customSalesOrderNumber,
    "production_item": productionItem,
    "employee": employee,
    "custom_designer": customDesigner,
    "custom_printing_person": customPrintingPerson,
    "custom_finishing_person": customFinishingPerson,
    "operation": operation,
    "posting_date":
        "${postingDate.year.toString().padLeft(4, '0')}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}",
    "company": company,
    "customer": customer,
    "custom_customer_name": customCustomerName,
    "status": status,
    "custom_job_status": customJobStatus,
    "custom_service_type": customServiceType,
    "custom_design_file": customDesignFile,
    "expected_start_date": expectedStartDate,
    "expected_time_required_in_mins": expectedTimeRequiredInMins,
    "expected_end_date": expectedEndDate,
    "actual_start_date": actualStartDate,
    "total_time_in_mins": totalTimeInMins,
    "actual_end_date": actualEndDate,
    "amended_from": amendedFrom,
    "doctype": doctype,
    "custom_print_items": List<dynamic>.from(customPrintItems.map((x) => x)),
    "time_logs": List<dynamic>.from(timeLogs.map((x) => x.toJson())),
    "custom_employees": List<dynamic>.from(
      customEmployees.map((x) => x.toJson()),
    ),
    "custom_items": List<dynamic>.from(customItems.map((x) => x.toJson())),
    "scheduled_time_logs": List<dynamic>.from(scheduledTimeLogs.map((x) => x)),
  };
}

class CustomEmployee {
  String name;
  String owner;
  DateTime creation;
  DateTime modified;
  String modifiedBy;
  double docstatus;
  double idx;
  String employees;
  String name1;
  double isPercentage;
  double percentage;
  double commission;
  String parent;
  String parentfield;
  String parenttype;
  String doctype;

  CustomEmployee({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    required this.employees,
    required this.name1,
    required this.isPercentage,
    required this.percentage,
    required this.commission,
    required this.parent,
    required this.parentfield,
    required this.parenttype,
    required this.doctype,
  });

  factory CustomEmployee.fromJson(Map<String, dynamic> json) => CustomEmployee(
    name: json["name"] ?? "",
    owner: json["owner"] ?? "",
    creation: DateTime.parse(json["creation"]),
    modified: DateTime.parse(json["modified"]),
    modifiedBy: json["modified_by"] ?? "",
    docstatus: json["docstatus"]?.toDouble() ?? 0.0,
    idx: json["idx"]?.toDouble() ?? 0.0,
    employees: json["employees"] ?? "",
    name1: json["name1"] ?? "",
    isPercentage: json["is_percentage"]?.toDouble() ?? 0.0,
    percentage: json["percentage"]?.toDouble() ?? 0.0,
    commission: json["commission"]?.toDouble() ?? 0.0,
    parent: json["parent"] ?? "",
    parentfield: json["parentfield"] ?? "",
    parenttype: json["parenttype"] ?? "",
    doctype: json["doctype"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation.toIso8601String(),
    "modified": modified.toIso8601String(),
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "employees": employees,
    "name1": name1,
    "is_percentage": isPercentage,
    "percentage": percentage,
    "commission": commission,
    "parent": parent,
    "parentfield": parentfield,
    "parenttype": parenttype,
    "doctype": doctype,
  };
}

class CustomItem {
  String name;
  String owner;
  DateTime creation;
  DateTime modified;
  String modifiedBy;
  double docstatus;
  double idx;
  String itemName;
  double copies;
  double designCost;
  dynamic remarks;
  String parent;
  String parentfield;
  String parenttype;
  String doctype;

  CustomItem({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    required this.itemName,
    required this.copies,
    required this.designCost,
    required this.remarks,
    required this.parent,
    required this.parentfield,
    required this.parenttype,
    required this.doctype,
  });

  factory CustomItem.fromJson(Map<String, dynamic> json) => CustomItem(
    name: json["name"] ?? "",
    owner: json["owner"] ?? "",
    creation: DateTime.parse(json["creation"]),
    modified: DateTime.parse(json["modified"]),
    modifiedBy: json["modified_by"] ?? "",
    docstatus: json["docstatus"]?.toDouble() ?? 0.0,
    idx: json["idx"]?.toDouble() ?? 0.0,
    itemName: json["item_name"] ?? "",
    copies: json["copies"]?.toDouble() ?? 0.0,
    designCost: json["design_cost"]?.toDouble() ?? 0.0,
    remarks: json["remarks"],
    parent: json["parent"] ?? "",
    parentfield: json["parentfield"] ?? "",
    parenttype: json["parenttype"] ?? "",
    doctype: json["doctype"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation.toIso8601String(),
    "modified": modified.toIso8601String(),
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "item_name": itemName,
    "copies": copies,
    "design_cost": designCost,
    "remarks": remarks,
    "parent": parent,
    "parentfield": parentfield,
    "parenttype": parenttype,
    "doctype": doctype,
  };
}

class TimeLog {
  String name;
  String owner;
  DateTime? creation;
  DateTime? modified;
  String modifiedBy;
  double docstatus;
  double idx;
  DateTime? fromTime;
  DateTime? toTime;
  double timeInMins;
  String employee;
  String parent;
  String parentfield;
  String parenttype;
  String doctype;

  TimeLog({
    required this.name,
    required this.owner,
    this.creation,
    this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    this.fromTime,
    this.toTime,
    required this.timeInMins,
    required this.employee,
    required this.parent,
    required this.parentfield,
    required this.parenttype,
    required this.doctype,
  });

  factory TimeLog.fromJson(Map<String, dynamic> json) => TimeLog(
    name: json["name"] ?? '',
    owner: json["owner"] ?? '',
    creation: json["creation"] != null ? DateTime.tryParse(json["creation"]) : null,
    modified: json["modified"] != null ? DateTime.tryParse(json["modified"]) : null,
    modifiedBy: json["modified_by"] ?? '',
    docstatus: json["docstatus"]?.toDouble() ?? 0.0,
    idx: json["idx"]?.toDouble() ?? 0.0,
    fromTime: json["from_time"] != null ? DateTime.tryParse(json["from_time"]) : null,
    toTime: json["to_time"] != null ? DateTime.tryParse(json["to_time"]) : null,
    timeInMins: json["time_in_mins"]?.toDouble() ?? 0.0,
    employee: json["employee"] ?? '',
    parent: json["parent"] ?? '',
    parentfield: json["parentfield"] ?? '',
    parenttype: json["parenttype"] ?? '',
    doctype: json["doctype"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation?.toIso8601String(),
    "modified": modified?.toIso8601String(),
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "from_time": fromTime?.toIso8601String(),
    "to_time": toTime?.toIso8601String(),
    "time_in_mins": timeInMins,
    "employee": employee,
    "parent": parent,
    "parentfield": parentfield,
    "parenttype": parenttype,
    "doctype": doctype,
  };
}
