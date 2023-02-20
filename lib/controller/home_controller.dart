import "dart:io";
import "dart:math" show cos, sqrt, asin;

import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_polyline_points/flutter_polyline_points.dart";
import "package:geolocator/geolocator.dart";
import "package:get/get.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:google_maps_integration/constant/key_constant.dart";
import "package:place_picker/entities/location_result.dart";

enum LocationFor { source, destination }

enum MapStyle { standard, silver, retro, dark, night, aubergine }

class HomeController extends GetxController {
  Rx<BitmapDescriptor> myLocationBitmap = BitmapDescriptor.defaultMarker.obs;
  Rx<BitmapDescriptor> markerNum1Bitmap = BitmapDescriptor.defaultMarker.obs;
  Rx<BitmapDescriptor> markerNum2Bitmap = BitmapDescriptor.defaultMarker.obs;
  RxString sourceStr = "".obs;
  RxDouble sourceLat = 0.0.obs;
  RxDouble sourceLon = 0.0.obs;
  RxString destinStr = "".obs;
  RxDouble destinLat = 0.0.obs;
  RxDouble destinLon = 0.0.obs;
  Rx<LatLng> currentPosition = const LatLng(0, 0).obs;
  final Rx<CameraPosition> initPos = const CameraPosition(
    target: LatLng(0.0, 0.0),
  ).obs;
  Set<Marker> markers = <Marker>{}.obs;
  Rx<PolylinePoints> polylinePoints = PolylinePoints().obs;
  List<LatLng> polylineCoordinates = <LatLng>[].obs;
  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;

  Future<void> init(Position position) async {
    currentPosition(
      LatLng(position.latitude, position.longitude),
    );
    final Marker marker = Marker(
      markerId: const MarkerId("my_location"),
      position: currentPosition.value,
      infoWindow: InfoWindow(
        title: "My Location",
        snippet: currentPosition.value.toString(),
      ),
      icon: await getMyLocationIcon(),
    );
    markers.add(marker);
    return;
  }

  LatLng showPlacePicker(LocationFor locationFor) {
    LatLng latLng = const LatLng(0, 0);
    switch (locationFor) {
      case LocationFor.source:
        final double latitude = sourceLat.value;
        final double longitude = sourceLon.value;
        latLng = LatLng(latitude, longitude) == latLng
            ? currentPosition.value
            : LatLng(latitude, longitude);
        break;
      case LocationFor.destination:
        final double latitude = destinLat.value;
        final double longitude = destinLon.value;
        latLng = LatLng(latitude, longitude) == latLng
            ? currentPosition.value
            : LatLng(latitude, longitude);
        break;
    }
    return latLng;
  }

  void result(LocationFor locationFor, LocationResult? result) {
    final LatLng latLng = result?.latLng ?? const LatLng(0, 0);
    switch (locationFor) {
      case LocationFor.source:
        sourceStr(result?.name ?? "");
        sourceLat(latLng.latitude);
        sourceLon(latLng.longitude);
        break;
      case LocationFor.destination:
        destinStr(result?.name ?? "");
        destinLat(latLng.latitude);
        destinLon(latLng.longitude);
        break;
    }
    polyLines.clear();
    return;
  }

  Future<void> markerSetup(
    LocationFor locationFor,
    Function(LatLng position) onTap,
  ) async {
    MarkerId markerId = const MarkerId("");
    LatLng latLng = const LatLng(0, 0);
    InfoWindow infoWindow = InfoWindow.noText;
    switch (locationFor) {
      case LocationFor.source:
        markerId = const MarkerId("sourceId");
        final double latitude = sourceLat.value;
        final double longitude = sourceLon.value;
        latLng = LatLng(latitude, longitude);
        infoWindow = InfoWindow(
          title: sourceStr.value,
          snippet: LatLng(latitude, longitude).toString(),
        );
        break;
      case LocationFor.destination:
        markerId = const MarkerId("destinationId");
        final double latitude = destinLat.value;
        final double longitude = destinLon.value;
        latLng = LatLng(latitude, longitude);
        infoWindow = InfoWindow(
          title: destinStr.value,
          snippet: LatLng(latitude, longitude).toString(),
        );
        break;
    }
    markers.removeWhere((Marker e) => e.mapsId == markerId);
    final Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      infoWindow: infoWindow,
      icon: await getMarkerIcon(locationFor),
      onTap: () {
        onTap(latLng);
      },
    );
    markers.add(marker);
    return;
  }

  Future<void> animateToMarker(
    LocationFor locationFor,
    Function(LatLng) latLngCallback,
  ) async {
    LatLng latLng = const LatLng(0, 0);
    switch (locationFor) {
      case LocationFor.source:
        final double latitude = sourceLat.value;
        final double longitude = sourceLon.value;
        latLng = LatLng(latitude, longitude);
        break;
      case LocationFor.destination:
        final double latitude = destinLat.value;
        final double longitude = destinLon.value;
        latLng = LatLng(latitude, longitude);
        break;
    }
    latLngCallback(latLng);
    return Future<void>.value();
  }

  Future<void> calcAndAnimateToRoute(
    Function(CameraUpdate) latLngCallback,
  ) async {
    final double minY = (sourceLat.value <= destinLat.value)
        ? sourceLat.value
        : destinLat.value;
    final double minX = (sourceLon.value <= destinLon.value)
        ? sourceLon.value
        : destinLon.value;
    final double maxY = (sourceLat.value <= destinLat.value)
        ? destinLat.value
        : sourceLat.value;
    final double maxX = (sourceLon.value <= destinLon.value)
        ? destinLon.value
        : sourceLon.value;
    final double southWestLatitude = minY;
    final double southWestLongitude = minX;
    final double northEastLatitude = maxY;
    final double northEastLongitude = maxX;
    final CameraUpdate newLatLngBounds = CameraUpdate.newLatLngBounds(
      LatLngBounds(
        northeast: LatLng(northEastLatitude, northEastLongitude),
        southwest: LatLng(southWestLatitude, southWestLongitude),
      ),
      100.0,
    );
    latLngCallback(newLatLngBounds);
    return Future<void>.value();
  }

  Future<void> rollBackNavigation(
    LocationFor locationFor,
    Function(LatLng) latLngCallback,
  ) async {
    LatLng latLng = const LatLng(0, 0);
    switch (locationFor) {
      case LocationFor.source:
        final double latitude = destinLat.value;
        final double longitude = destinLon.value;
        final LatLng currentPositionLatLng = currentPosition.value;
        latLng = LatLng(latitude, longitude) == latLng
            ? currentPositionLatLng
            : LatLng(latitude, longitude);
        break;
      case LocationFor.destination:
        final double latitude = sourceLat.value;
        final double longitude = sourceLon.value;
        final LatLng currentPositionLatLng = currentPosition.value;
        latLng = LatLng(latitude, longitude) == latLng
            ? currentPositionLatLng
            : LatLng(latitude, longitude);
        break;
    }
    latLngCallback(latLng);
    return Future<void>.value();
  }

  void resetSpecific(LocationFor locationFor) {
    MarkerId markerId = const MarkerId("");
    switch (locationFor) {
      case LocationFor.source:
        sourceStr("");
        sourceLat(0);
        sourceLon(0);
        polyLines.clear();
        markerId = const MarkerId("sourceId");
        break;
      case LocationFor.destination:
        destinStr("");
        destinLat(0);
        destinLon(0);
        polyLines.clear();
        markerId = const MarkerId("destinationId");
        break;
    }
    markers.removeWhere((Marker e) => e.mapsId == markerId);
    return;
  }

  Future<BitmapDescriptor> getMyLocationIcon() async {
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
    bitmapDescriptor = myLocationBitmap.value == bitmapDescriptor
        ? myLocationBitmap(
            await findMyLocationIcon(),
          )
        : myLocationBitmap.value;
    return Future<BitmapDescriptor>.value(bitmapDescriptor);
  }

  Future<BitmapDescriptor> findMyLocationIcon() async {
    final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/markers/${operatingSystemName()}my_location.png",
    );
    return Future<BitmapDescriptor>.value(markerIcon);
  }

  Future<BitmapDescriptor> getMarkerIcon(LocationFor locationFor) async {
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
    switch (locationFor) {
      case LocationFor.source:
        bitmapDescriptor = markerNum1Bitmap.value == bitmapDescriptor
            ? markerNum1Bitmap(
                await findMarkerIcon(locationFor),
              )
            : markerNum1Bitmap.value;
        break;
      case LocationFor.destination:
        bitmapDescriptor = markerNum2Bitmap.value == bitmapDescriptor
            ? markerNum2Bitmap(
                await findMarkerIcon(locationFor),
              )
            : markerNum2Bitmap.value;
        break;
    }
    return Future<BitmapDescriptor>.value(bitmapDescriptor);
  }

  Future<BitmapDescriptor> findMarkerIcon(LocationFor locationFor) async {
    String assetName = "";
    switch (locationFor) {
      case LocationFor.source:
        assetName = "assets/markers/${operatingSystemName()}mark_one.png";
        break;
      case LocationFor.destination:
        assetName = "assets/markers/${operatingSystemName()}mark_two.png";
        break;
    }
    final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      assetName,
    );
    return Future<BitmapDescriptor>.value(markerIcon);
  }

  String operatingSystemName() {
    return Platform.isIOS
        ? "ios/"
        : Platform.isAndroid
            ? "android/"
            : "";
  }

  Future<void> createPolyLines() async {
    polylinePoints = PolylinePoints().obs;
    PolylineResult result = PolylineResult();
    result = await polylinePoints.value.getRouteBetweenCoordinates(
      KeyConstant().apiKey,
      PointLatLng(sourceLat.value, sourceLon.value),
      PointLatLng(destinLat.value, destinLon.value),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (final PointLatLng point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }
    const PolylineId id = PolylineId("poly");
    final Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 3,
    );
    polyLines[id] = polyline;
    return Future<void>.value();
  }

  double coordinateDistance(double lt1, double ln1, double lt2, double ln2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        cos((lt2 - lt1) * p) / 2 +
        cos(lt1 * p) * cos(lt2 * p) * (1 - cos((ln2 - ln1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String totalDistance() {
    double totalDistance = 0.0;
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    return totalDistance.toStringAsFixed(2);
  }

  Rx<MapStyle> defaultStyle = MapStyle.standard.obs;

  Future<String> setStyle(MapStyle style) async {
    defaultStyle(style);
    final String key = "assets/styles/${style.name}.json";
    final String value = await rootBundle.loadString(key);
    return Future<String>.value(value);
  }
}
