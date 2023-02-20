import "dart:developer";

import "package:geolocator/geolocator.dart" as geo;
import "package:location/location.dart" as loc;
import "package:permission_handler/permission_handler.dart";

class LocationService {
  factory LocationService() {
    return _singleton;
  }

  LocationService._internal();

  static final LocationService _singleton = LocationService._internal();

  Future<PermissionStatus> functionPermissionStatus() async {
    final PermissionStatus permStatus = await Permission.location.request();
    String text = "";
    switch (permStatus) {
      case PermissionStatus.denied:
        text = "Location permission is denied.";
        break;
      case PermissionStatus.granted:
        text = "Location permission is granted.";
        break;
      case PermissionStatus.restricted:
        text = "Location permission is restricted.";
        break;
      case PermissionStatus.limited:
        text = "Location permission is limited.";
        break;
      case PermissionStatus.permanentlyDenied:
        text = "Location permission is permanently denied.";
        break;
    }
    log("functionPermissionStatus() : $text");
    return Future<PermissionStatus>.value(permStatus);
  }

  Future<ServiceStatus> functionServiceStatus() async {
    ServiceStatus serviceStatus = await Permission.location.serviceStatus;
    String text = "";
    switch (serviceStatus) {
      case ServiceStatus.disabled:
        final bool serviceEnabled = await loc.Location().requestService();
        // final bool serviceEnabled = false;
        if (serviceEnabled) {
          serviceStatus = ServiceStatus.enabled;
          text = "Location service request is approved.";
        } else {
          text = "Location service request is refused.";
        }
        break;
      case ServiceStatus.enabled:
        text = "Location service is enabled.";
        break;
      case ServiceStatus.notApplicable:
        text = "Location service is not applicable.";
        break;
    }
    log("functionServiceStatus() : $text");
    return Future<ServiceStatus>.value(serviceStatus);
  }

  Future<geo.Position> getPosition({
    required bool mounted,
  }) async {
    final PermissionStatus permissionStatus = await functionPermissionStatus();
    if (permissionStatus == PermissionStatus.granted) {
      if (mounted) {
        final ServiceStatus serviceStatus = await functionServiceStatus();
        if (serviceStatus == ServiceStatus.enabled) {
          final geo.Position pos = await geo.Geolocator.getCurrentPosition();
          return Future<geo.Position>.value(pos);
        } else {
          const String text = "Location service request is refused.";
          return Future<geo.Position>.error(text);
        }
      } else {
        const String text = "Widget is not mounted";
        return Future<geo.Position>.error(text);
      }
    } else {
      const String text = "Location permission is denied.";
      return Future<geo.Position>.error(text);
    }
  }
}
