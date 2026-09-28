class AuthModel {
  int? statusCode;
  String? message;
  Data? data;

  AuthModel({this.statusCode, this.message, this.data});

  AuthModel.fromJson(Map<String, dynamic> json) {
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
  String? token;
  User? user;

  Data({this.token, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? fullName;
  String? mobileNo;
  String? email;
  String? address;
  String? role;
  bool? isDeleted;
  bool? isVerified;
  bool? isForgotPassword;
  bool? isActive;
  bool? isSubscribedForCommercial;
  bool? isSubscribedForResidential;
  String? createdAt;
  String? updatedAt;
  int? iV;

  User(
      {this.sId,
      this.fullName,
      this.mobileNo,
      this.email,
      this.address,
      this.role,
      this.isDeleted,
      this.isVerified,
      this.isForgotPassword,
      this.isActive,
      this.isSubscribedForCommercial,
      this.isSubscribedForResidential,
      this.createdAt,
      this.updatedAt,
      this.iV});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    mobileNo = json['mobileNo'];
    email = json['email'];
    address = json['address'];
    role = json['role'];
    isDeleted = json['isDeleted'];
    isVerified = json['isVerified'];
    isForgotPassword = json['isForgotPassword'];
    isActive = json['isActive'];
    isSubscribedForCommercial = json['isSubscribedForCommercial'];
    isSubscribedForResidential = json['isSubscribedForResidential'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['mobileNo'] = mobileNo;
    data['email'] = email;
    data['address'] = address;
    data['role'] = role;
    data['isDeleted'] = isDeleted;
    data['isVerified'] = isVerified;
    data['isForgotPassword'] = isForgotPassword;
    data['isActive'] = isActive;
    data['isSubscribedForCommercial'] = isSubscribedForCommercial;
    data['isSubscribedForResidential'] = isSubscribedForResidential;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
