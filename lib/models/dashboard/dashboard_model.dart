class DashboardModel {
  int? statusCode;
  String? message;
  Data? data;

  DashboardModel({this.statusCode, this.message, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  Broker? broker;
  int? totalProperties;
  int? activeProperties;
  int? closedDeals;

  Data(
      {this.broker,
      this.totalProperties,
      this.activeProperties,
      this.closedDeals});

  Data.fromJson(Map<String, dynamic> json) {
    broker = json['broker'] != null ? Broker.fromJson(json['broker']) : null;
    totalProperties = json['totalProperties'];
    activeProperties = json['activeProperties'];
    closedDeals = json['closedDeals'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (broker != null) {
      data['broker'] = broker!.toJson();
    }
    data['totalProperties'] = totalProperties;
    data['activeProperties'] = activeProperties;
    data['closedDeals'] = closedDeals;
    return data;
  }
}

class Broker {
  String? sId;
  String? fullName;
  String? mobileNo;
  String? email;

  Broker({this.sId, this.fullName, this.mobileNo, this.email});

  Broker.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    mobileNo = json['mobileNo'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['mobileNo'] = mobileNo;
    data['email'] = email;
    return data;
  }
}
