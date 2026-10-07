class ScheduleVisitModel {
  final int? statusCode;
  final String? message;
  final dynamic data;

  ScheduleVisitModel({this.statusCode, this.message, this.data});

  factory ScheduleVisitModel.fromJson(Map<String, dynamic> json) {
    return ScheduleVisitModel(
      statusCode: json['statusCode'],
      message: json['message'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}
