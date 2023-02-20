class PlaceIdModel {
  PlaceIdModel({
    this.plusCode,
    this.results,
    this.status,
  });

  PlaceIdModel.fromJson(Map<String, dynamic> json) {
    plusCode =
        json["plus_code"] != null ? PlusCode.fromJson(json["plus_code"]) : null;
    if (json["results"] != null) {
      results = <Results>[];
      for (final dynamic v in json["results"] as List<dynamic>) {
        results?.add(Results.fromJson(v));
      }
    }
    status = json["status"];
  }

  PlusCode? plusCode;
  List<Results>? results;
  String? status;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (plusCode != null) {
      map["plus_code"] = plusCode?.toJson();
    }
    if (results != null) {
      map["results"] = results?.map((Results v) => v.toJson()).toList();
    }
    map["status"] = status;
    return map;
  }
}

class Results {
  Results({
    this.addressComponents,
    this.formattedAddress,
    this.geometry,
    this.placeId,
    this.plusCode,
    this.types,
  });

  Results.fromJson(Map<String, dynamic> json) {
    if (json["address_components"] != null) {
      addressComponents = <AddressComponents>[];
      for (final dynamic v in json["address_components"] as List<dynamic>) {
        addressComponents?.add(AddressComponents.fromJson(v));
      }
    }
    formattedAddress = json["formatted_address"];
    geometry =
        json["geometry"] != null ? Geometry.fromJson(json["geometry"]) : null;
    placeId = json["place_id"];
    plusCode =
        json["plus_code"] != null ? PlusCode.fromJson(json["plus_code"]) : null;
    types = json["types"] != null
        ? (json["types"] as List<dynamic>).cast<String>()
        : <String>[];
  }

  List<AddressComponents>? addressComponents;
  String? formattedAddress;
  Geometry? geometry;
  String? placeId;
  PlusCode? plusCode;
  List<String>? types;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (addressComponents != null) {
      map["address_components"] =
          addressComponents?.map((AddressComponents v) => v.toJson()).toList();
    }
    map["formatted_address"] = formattedAddress;
    if (geometry != null) {
      map["geometry"] = geometry?.toJson();
    }
    map["place_id"] = placeId;
    if (plusCode != null) {
      map["plus_code"] = plusCode?.toJson();
    }
    map["types"] = types;
    return map;
  }
}

class PlusCode {
  PlusCode({
    this.compoundCode,
    this.globalCode,
  });

  PlusCode.fromJson(Map<String, dynamic> json) {
    compoundCode = json["compound_code"];
    globalCode = json["global_code"];
  }

  String? compoundCode;
  String? globalCode;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["compound_code"] = compoundCode;
    map["global_code"] = globalCode;
    return map;
  }
}

class Geometry {
  Geometry({
    this.location,
    this.locationType,
    this.viewport,
  });

  Geometry.fromJson(Map<String, dynamic> json) {
    location =
        json["location"] != null ? Location.fromJson(json["location"]) : null;
    locationType = json["location_type"];
    viewport =
        json["viewport"] != null ? Viewport.fromJson(json["viewport"]) : null;
  }

  Location? location;
  String? locationType;
  Viewport? viewport;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (location != null) {
      map["location"] = location?.toJson();
    }
    map["location_type"] = locationType;
    if (viewport != null) {
      map["viewport"] = viewport?.toJson();
    }
    return map;
  }
}

class Viewport {
  Viewport({
    this.northeast,
    this.southwest,
  });

  Viewport.fromJson(Map<String, dynamic> json) {
    northeast = json["northeast"] != null
        ? Northeast.fromJson(json["northeast"])
        : null;
    southwest = json["southwest"] != null
        ? Southwest.fromJson(json["southwest"])
        : null;
  }

  Northeast? northeast;
  Southwest? southwest;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (northeast != null) {
      map["northeast"] = northeast?.toJson();
    }
    if (southwest != null) {
      map["southwest"] = southwest?.toJson();
    }
    return map;
  }
}

class Southwest {
  Southwest({
    this.lat,
    this.lng,
  });

  Southwest.fromJson(Map<String, dynamic> json) {
    lat = json["lat"];
    lng = json["lng"];
  }

  double? lat;
  double? lng;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["lat"] = lat;
    map["lng"] = lng;
    return map;
  }
}

class Northeast {
  Northeast({
    this.lat,
    this.lng,
  });

  Northeast.fromJson(Map<String, dynamic> json) {
    lat = json["lat"];
    lng = json["lng"];
  }

  double? lat;
  double? lng;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["lat"] = lat;
    map["lng"] = lng;
    return map;
  }
}

class Location {
  Location({
    this.lat,
    this.lng,
  });

  Location.fromJson(Map<String, dynamic> json) {
    lat = json["lat"];
    lng = json["lng"];
  }

  double? lat;
  double? lng;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["lat"] = lat;
    map["lng"] = lng;
    return map;
  }
}

class AddressComponents {
  AddressComponents({
    this.longName,
    this.shortName,
    this.types,
  });

  AddressComponents.fromJson(Map<String, dynamic> json) {
    longName = json["long_name"];
    shortName = json["short_name"];
    types = json["types"] != null
        ? (json["types"] as List<dynamic>).cast<String>()
        : <String>[];
  }

  String? longName;
  String? shortName;
  List<String>? types;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["long_name"] = longName;
    map["short_name"] = shortName;
    map["types"] = types;
    return map;
  }
}
