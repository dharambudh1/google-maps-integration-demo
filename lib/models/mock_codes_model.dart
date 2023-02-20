class MockCodesModel {
  MockCodesModel({
    this.statusCode,
    this.description,
  });

  MockCodesModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    description = json["description"];
  }

  int? statusCode;
  String? description;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["statusCode"] = statusCode;
    map["description"] = description;
    return map;
  }
}
