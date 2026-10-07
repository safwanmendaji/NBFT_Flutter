class MySubscriptionModel {
  final int? statusCode;
  final String? message;
  final SubscriptionData? data;

  MySubscriptionModel({this.statusCode, this.message, this.data});

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      statusCode: json['statusCode'],
      message: json['message'],
      data: json['data'] != null ? SubscriptionData.fromJson(json['data']) : null,
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

class SubscriptionData {
  final String? id;
  final String? userId;
  final String? startDate;
  final String? endDate;
  final String? customerPropertyRequirementId;
  final int? amountPaid;
  final bool? isRefunded;
  final int? earnAmount;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final int? v;
  final int? totalDays;
  final CustomerPropertyRequirement? customerPropertyRequirement;

  SubscriptionData({
    this.id,
    this.userId,
    this.startDate,
    this.endDate,
    this.customerPropertyRequirementId,
    this.amountPaid,
    this.isRefunded,
    this.earnAmount,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.v,
    this.totalDays,
    this.customerPropertyRequirement,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['_id'],
      userId: json['userId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      customerPropertyRequirementId: json['customerPropertyRequirementId'],
      amountPaid: json['amountPaid'],
      isRefunded: json['isRefunded'],
      earnAmount: json['earnAmount'],
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      v: json['__v'],
      totalDays: json['totalDays'],
      customerPropertyRequirement: json['customerPropertyRequirement'] != null
          ? CustomerPropertyRequirement.fromJson(json['customerPropertyRequirement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['userId'] = userId;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['customerPropertyRequirementId'] = customerPropertyRequirementId;
    data['amountPaid'] = amountPaid;
    data['isRefunded'] = isRefunded;
    data['earnAmount'] = earnAmount;
    data['razorpayOrderId'] = razorpayOrderId;
    data['razorpayPaymentId'] = razorpayPaymentId;
    data['__v'] = v;
    data['totalDays'] = totalDays;
    if (customerPropertyRequirement != null) {
      data['customerPropertyRequirement'] = customerPropertyRequirement!.toJson();
    }
    return data;
  }
}

class CustomerPropertyRequirement {
  final String? id;
  final String? propertyPurpose;
  final String? propertyType;
  final String? floor;
  final String? furnished;
  final String? format;
  final String? state;
  final String? city;
  final String? area;
  final String? pincode;
  final String? size;
  final String? priceRange;
  final String? userDetails;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CustomerPropertyRequirement({
    this.id,
    this.propertyPurpose,
    this.propertyType,
    this.floor,
    this.furnished,
    this.format,
    this.state,
    this.city,
    this.area,
    this.pincode,
    this.size,
    this.priceRange,
    this.userDetails,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CustomerPropertyRequirement.fromJson(Map<String, dynamic> json) {
    return CustomerPropertyRequirement(
      id: json['_id'],
      propertyPurpose: json['propertyPurpose'],
      propertyType: json['propertyType'],
      floor: json['floor'],
      furnished: json['furnished'],
      format: json['format'],
      state: json['state'],
      city: json['city'],
      area: json['area'],
      pincode: json['pincode']?.toString(),
      size: json['size'],
      priceRange: json['priceRange']?.toString(),
      userDetails: json['userDetails'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['propertyPurpose'] = propertyPurpose;
    data['propertyType'] = propertyType;
    data['floor'] = floor;
    data['furnished'] = furnished;
    data['format'] = format;
    data['state'] = state;
    data['city'] = city;
    data['area'] = area;
    data['pincode'] = pincode;
    data['size'] = size;
    data['priceRange'] = priceRange;
    data['userDetails'] = userDetails;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    return data;
  }
}
