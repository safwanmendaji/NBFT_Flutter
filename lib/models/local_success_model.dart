// for use manage all error types

class LocalSuccesModel {
  int? status;
  String? message;

  LocalSuccesModel({this.status, this.message});

  LocalSuccesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }
  LocalSuccesModel.fromJsonWithCode(response) {
    status = response["status"];
    message = response["message"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;

    return data;
  }
}
