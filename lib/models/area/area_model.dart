class AreaModel {
  String? message;
  Pagination? pagination;
  List<Areas>? areas;

  AreaModel({this.message, this.pagination, this.areas});

  AreaModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    pagination =
        json['pagination'] != null
            ? new Pagination.fromJson(json['pagination'])
            : null;
    if (json['areas'] != null) {
      areas = <Areas>[];
      json['areas'].forEach((v) {
        areas!.add(new Areas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.areas != null) {
      data['areas'] = this.areas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalRecords;

  Pagination({this.currentPage, this.totalPages, this.totalRecords});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    totalRecords = json['totalRecords'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    data['totalRecords'] = this.totalRecords;
    return data;
  }
}

class Areas {
  String? sId;
  String? areaName;
  int? pincode;
  bool? isActive;

  Areas({this.sId, this.areaName, this.pincode, this.isActive});

  Areas.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    areaName = json['areaName'];
    pincode = json['pincode'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['areaName'] = this.areaName;
    data['pincode'] = this.pincode;
    data['isActive'] = this.isActive;
    return data;
  }
}
