class AddPropertyModel {
  int? statusCode;
  String? message;
  Data? data;

  AddPropertyModel({this.statusCode, this.message, this.data});

  AddPropertyModel.fromJson(Map<String, dynamic> json) {
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
  String? title;
  int? price;
  String? area;
  String? floor;
  String? location;
  String? description;
  String? type;
  String? category;
  String? format;
  String? sizeType;
  String? furnished;
  String? status;
  String? postedBy;
  List<Media>? media;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.title,
      this.price,
      this.area,
      this.floor,
      this.location,
      this.description,
      this.type,
      this.category,
      this.format,
      this.sizeType,
      this.furnished,
      this.status,
      this.postedBy,
      this.media,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    price = json['price'];
    area = json['area'];
    floor = json['floor'];
    location = json['location'];
    description = json['description'];
    type = json['type'];
    category = json['category'];
    format = json['format'];
    sizeType = json['sizeType'];
    furnished = json['furnished'];
    status = json['status'];
    postedBy = json['postedBy'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['price'] = price;
    data['area'] = area;
    data['floor'] = floor;
    data['location'] = location;
    data['description'] = description;
    data['type'] = type;
    data['category'] = category;
    data['format'] = format;
    data['sizeType'] = sizeType;
    data['furnished'] = furnished;
    data['status'] = status;
    data['postedBy'] = postedBy;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Media {
  String? type;
  String? path;
  String? sId;

  Media({this.type, this.path, this.sId});

  Media.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    path = json['path'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['path'] = path;
    data['_id'] = sId;
    return data;
  }
}
