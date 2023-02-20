import "dart:async";

import "package:geocoding/geocoding.dart";
import "package:get/get.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:google_maps_integration/constant/key_constant.dart";
import "package:google_maps_integration/models/place_model.dart";
import "package:google_maps_integration/models/reference_model.dart";
import "package:google_maps_integration/services/network_service.dart";
import "package:place_picker/place_picker.dart";

class SheetController extends GetxController {
  final NetworkService networkServiceController = Get.put(
    NetworkService(),
  );

  Rx<Future<dynamic>> futuresList = Future<dynamic>.value().obs;

  Future<void> updateFuture(LatLng latLng) async {
    await futuresList(
      Future.wait(
        <Future<dynamic>>[
          getPlaceMarkData(latLng),
          getPlacePhotosData(latLng),
        ],
      ),
    );
    return Future<void>.value();
  }

  Future<Placemark> getPlaceMarkData(LatLng latLng) async {
    final List<Placemark> placeMarkList = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    final Placemark placeMark = placeMarkList[0];
    return Future<Placemark>.value(placeMark);
  }

  Future<List<String>> getPlacePhotosData(LatLng latLng) async {
    final String id = await placeId(latLng);
    final List<String> ref = await photoReference(id);
    final List<String> list = await getPics(ref);
    return Future<List<String>>.value(list);
  }

  Future<String> placeId(LatLng latLng) async {
    String placeId = "";
    Map<String, dynamic> req = <String, dynamic>{};
    req = <String, dynamic>{
      "latlng": "${latLng.latitude}, ${latLng.longitude}",
      "key": KeyConstant().apiKey,
    };
    await networkServiceController.getRequest(
      point: "maps/api/geocode/json",
      request: req,
      decodedResponse: (Map<String, dynamic> p0) async {
        final PlaceIdModel model = PlaceIdModel.fromJson(p0);
        placeId = model.results?[0].placeId ?? "";
      },
      callbackHandle: (String p0) {},
    );
    return Future<String>.value(placeId);
  }

  Future<List<String>> photoReference(String placeId) async {
    final List<String> photoReferences = <String>[];
    Map<String, dynamic> req = <String, dynamic>{};
    req = <String, dynamic>{
      "place_id": placeId,
      "fields": "photo",
      "key": KeyConstant().apiKey,
    };
    await networkServiceController.getRequest(
      point: "maps/api/place/details/json",
      request: req,
      decodedResponse: (Map<String, dynamic> p0) async {
        final ReferenceModel model = ReferenceModel.fromJson(p0);
        model.result?.photos?.forEach(
          (Photos element) {
            photoReferences.add(element.photoReference ?? "");
          },
        );
      },
      callbackHandle: (String p0) {},
    );
    return Future<List<String>>.value(photoReferences);
  }

  Future<List<String>> getPics(List<String> photoReferences) async {
    final List<String> imageList = <String>[];
    const String baseURL = "https://maps.googleapis.com/maps/api/place/photo";
    const String height = "maxheight=300";
    const String width = "maxwidth=300";
    final String key = "key=${KeyConstant().apiKey}";
    await Future.forEach(
      photoReferences,
      (String element) async {
        final String ref = "photoreference=$element";
        imageList.add("$baseURL?$height&$width&$ref&$key");
      },
    );
    return Future<List<String>>.value(imageList);
  }
}
