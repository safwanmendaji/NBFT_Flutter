class VisitAvailabilityModel {
  final int? statusCode;
  final String? message;
  final AvailabilityData? data;

  VisitAvailabilityModel({this.statusCode, this.message, this.data});

  factory VisitAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return VisitAvailabilityModel(
      statusCode: json['statusCode'],
      message: json['message'],
      data: json['data'] != null ? AvailabilityData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AvailabilityData {
  final String? date;
  final int? dayOfWeek;
  final String? brokerId;
  final List<Slot>? slots;

  AvailabilityData({this.date, this.dayOfWeek, this.brokerId, this.slots});

  factory AvailabilityData.fromJson(Map<String, dynamic> json) {
    return AvailabilityData(
      date: json['date'],
      dayOfWeek: json['dayOfWeek'],
      brokerId: json['brokerId'],
      slots: json['slots'] != null
          ? (json['slots'] as List).map((v) => Slot.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['dayOfWeek'] = dayOfWeek;
    data['brokerId'] = brokerId;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Slot {
  final String? startTime;
  final bool? available;

  Slot({this.startTime, this.available});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      startTime: json['startTime'],
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['available'] = available;
    return data;
  }
}
