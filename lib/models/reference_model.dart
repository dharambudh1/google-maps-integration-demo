class ReferenceModel {
  ReferenceModel({
    this.htmlAttributions,
    this.result,
    this.status,
  });

  ReferenceModel.fromJson(Map<String, dynamic> json) {
    htmlAttributions = json["html_attributions"] != null
        ? (json["html_attributions"] as List<dynamic>).cast<String>()
        : <String>[];
    result = json["result"] != null ? Result.fromJson(json["result"]) : null;
    status = json["status"];
  }

  List<String>? htmlAttributions;
  Result? result;
  String? status;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["html_attributions"] = htmlAttributions;
    if (result != null) {
      map["result"] = result?.toJson();
    }
    map["status"] = status;
    return map;
  }
}

class Result {
  Result({
    this.photos,
  });

  Result.fromJson(Map<String, dynamic> json) {
    if (json["photos"] != null) {
      photos = <Photos>[];
      for (final dynamic v in json["photos"] as List<dynamic>) {
        photos?.add(Photos.fromJson(v));
      }
    }
  }

  List<Photos>? photos;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (photos != null) {
      map["photos"] = photos?.map((Photos v) => v.toJson()).toList();
    }
    return map;
  }
}

class Photos {
  Photos({
    this.height,
    this.htmlAttributions,
    this.photoReference,
    this.width,
  });

  Photos.fromJson(Map<String, dynamic> json) {
    height = json["height"];
    htmlAttributions = json["html_attributions"] != null
        ? (json["html_attributions"] as List<dynamic>).cast<String>()
        : <String>[];
    photoReference = json["photo_reference"];
    width = json["width"];
  }

  int? height;
  List<String>? htmlAttributions;
  String? photoReference;
  int? width;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["height"] = height;
    map["html_attributions"] = htmlAttributions;
    map["photo_reference"] = photoReference;
    map["width"] = width;
    return map;
  }
}
