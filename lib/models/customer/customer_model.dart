class GetCustomerModel {
  int? statusCode;
  String? message;
  Data? data;

  GetCustomerModel({this.statusCode, this.message, this.data});

  GetCustomerModel.fromJson(Map<String, dynamic> json) {
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
  List<CustomerData>? data;
  Pagination? pagination;

  Data({this.data, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CustomerData>[];
      json['data'].forEach((v) {
        data!.add(CustomerData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class CustomerData {
  String? sId;
  String? userId;
  SharedWith? sharedWith;
  String? propertyId;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<CustomerRequirements>? customerRequirements;

  CustomerData(
      {this.sId,
      this.userId,
      this.sharedWith,
      this.propertyId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.customerRequirements});

  CustomerData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    sharedWith = json['sharedWith'] != null
        ? SharedWith.fromJson(json['sharedWith'])
        : null;
    propertyId = json['propertyId'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['customerRequirements'] != null) {
      customerRequirements = <CustomerRequirements>[];
      json['customerRequirements'].forEach((v) {
        customerRequirements!.add(CustomerRequirements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    if (sharedWith != null) {
      data['sharedWith'] = sharedWith!.toJson();
    }
    data['propertyId'] = propertyId;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (customerRequirements != null) {
      data['customerRequirements'] =
          customerRequirements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SharedWith {
  String? sId;
  String? fullName;
  String? mobileNo;
  String? email;

  SharedWith({this.sId, this.fullName, this.mobileNo, this.email});

  SharedWith.fromJson(Map<String, dynamic> json) {
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

class CustomerRequirements {
  String? sId;
  String? propertyPurpose;
  String? propertyType;
  String? floor;
  String? furnished;
  String? format;
  String? state;
  String? city;
  String? area;
  String? size;
  String? priceRange;
  String? userDetails;
  String? createdAt;
  String? updatedAt;
  int? iV;

  CustomerRequirements(
      {this.sId,
      this.propertyPurpose,
      this.propertyType,
      this.floor,
      this.furnished,
      this.format,
      this.state,
      this.city,
      this.area,
      this.size,
      this.priceRange,
      this.userDetails,
      this.createdAt,
      this.updatedAt,
      this.iV});

  CustomerRequirements.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    propertyPurpose = json['propertyPurpose'];
    propertyType = json['propertyType'];
    floor = json['floor'];
    furnished = json['furnished'];
    format = json['format'];
    state = json['state'];
    city = json['city'];
    area = json['area'];
    size = json['size'];
    priceRange = json['priceRange'];
    userDetails = json['userDetails'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['propertyPurpose'] = propertyPurpose;
    data['propertyType'] = propertyType;
    data['floor'] = floor;
    data['furnished'] = furnished;
    data['format'] = format;
    data['state'] = state;
    data['city'] = city;
    data['area'] = area;
    data['size'] = size;
    data['priceRange'] = priceRange;
    data['userDetails'] = userDetails;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    return data;
  }
}
