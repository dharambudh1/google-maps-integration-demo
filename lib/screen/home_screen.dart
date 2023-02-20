import "dart:async";

import "package:after_layout/after_layout.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:get/get.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:google_maps_integration/constant/key_constant.dart";
import "package:google_maps_integration/controller/home_controller.dart";
import "package:google_maps_integration/screen/sheet_screen.dart";
import "package:google_maps_integration/services/location_service.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:place_picker/place_picker.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  final HomeController _controller = Get.put(
    HomeController(),
  );
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late GoogleMapController _mapController;

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _formKey.currentState?.reset();
    _formKey.currentState?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        const Color transparent = Colors.transparent;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Google Maps Demo"),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 18.0,
                ),
                child: IconButton(
                  onPressed: getCurrentPosition,
                  icon: const Icon(Icons.my_location_outlined),
                ),
              )
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                await calcAndAnimateToRoute();
                await _controller.createPolyLines();
                showSnackBar();
              }
            },
            child: const Icon(Icons.directions_outlined),
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 30.0),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    leading: const Icon(Icons.style_outlined, size: 20),
                    title: const Text("Map Style"),
                    children: <Widget>[
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: MapStyle.values.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 50,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final MapStyle style = MapStyle.values[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                            ),
                            child: Obx(
                              () {
                                return ActionChip(
                                  avatar: _controller.defaultStyle.value ==
                                          style
                                      ? const Icon(Icons.check_circle_outline)
                                      : const SizedBox(),
                                  onPressed: () async {
                                    final String string =
                                        await _controller.setStyle(style);
                                    await _mapController.setMapStyle(string);
                                  },
                                  label: SizedBox(
                                    width: 150,
                                    child: Text(
                                      GetUtils.capitalize(style.name) ?? "",
                                      style:
                                          Theme.of(context).textTheme.overline,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _sourceController,
                          onChanged: _controller.sourceStr,
                          decoration: InputDecoration(
                            isDense: true,
                            icon: const Icon(Icons.map_outlined),
                            labelText: GetUtils.capitalize(
                                  LocationFor.source.name,
                                ) ??
                                "",
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await resetSpecific(LocationFor.source);
                              },
                              icon: const Icon(Icons.close_outlined),
                            ),
                          ),
                          readOnly: true,
                          validator: (String? value) {
                            return value == null || value.isEmpty
                                ? "Please enter ${LocationFor.source.name}"
                                : null;
                          },
                          onTap: () async {
                            await showPlacePicker(LocationFor.source);
                          },
                        ),
                        TextFormField(
                          controller: _destinationController,
                          onChanged: _controller.destinStr,
                          decoration: InputDecoration(
                            isDense: true,
                            icon: const Icon(Icons.map_outlined),
                            labelText: GetUtils.capitalize(
                                  LocationFor.destination.name,
                                ) ??
                                "",
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await resetSpecific(LocationFor.destination);
                              },
                              icon: const Icon(Icons.close_outlined),
                            ),
                          ),
                          readOnly: true,
                          validator: (String? value) {
                            return value == null || value.isEmpty
                                ? "Please enter ${LocationFor.destination.name}"
                                : null;
                          },
                          onTap: () async {
                            await showPlacePicker(LocationFor.destination);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: _controller.initPos.value,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) async {
                      _mapController = controller;
                    },
                    markers: Set<Marker>.from(_controller.markers),
                    polylines: Set<Polyline>.of(_controller.polyLines.values),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showPlacePicker(LocationFor locationFor) async {
    removeCurrentSnackBar();
    final LocationResult? result = await Get.to(
      () {
        return PlacePicker(
          KeyConstant().apiKey,
          displayLocation: _controller.showPlacePicker(locationFor),
        );
      },
    );
    if (result != null) {
      switch (locationFor) {
        case LocationFor.source:
          _sourceController.text = result.name ?? "";
          break;
        case LocationFor.destination:
          _destinationController.text = result.name ?? "";
          break;
      }
      _controller.result(locationFor, result);
      await markerSetup(locationFor);
      await animateToMarker(locationFor);
    } else {}
  }

  Future<void> markerSetup(LocationFor locationFor) async {
    await _controller.markerSetup(
      locationFor,
      (LatLng position) async {
        await openBarModalBottomSheet(position);
      },
    );
    return;
  }

  Future<void> animateToMarker(LocationFor locationFor) async {
    await _controller.animateToMarker(locationFor, animateCamera);
    return Future<void>.value();
  }

  Future<void> calcAndAnimateToRoute() async {
    await _controller.calcAndAnimateToRoute(_mapController.animateCamera);
    return Future<void>.value();
  }

  Future<void> animateCamera(LatLng target) async {
    final CameraUpdate newCameraPosition = CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 15.0),
    );
    Timer(
      const Duration(milliseconds: 500),
      () async {
        await _mapController.animateCamera(newCameraPosition);
      },
    );
    return Future<void>.value();
  }

  Future<void> rollBackNavigation(LocationFor locationFor) async {
    await _controller.rollBackNavigation(locationFor, animateCamera);
    return Future<void>.value();
  }

  Future<void> resetSpecific(LocationFor locationFor) async {
    removeCurrentSnackBar();
    switch (locationFor) {
      case LocationFor.source:
        _sourceController.text = "";
        break;
      case LocationFor.destination:
        _destinationController.text = "";
        break;
    }
    _controller.resetSpecific(locationFor);
    await rollBackNavigation(locationFor);
    return Future<void>.value();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar() {
    final String totalDistance = _controller.totalDistance();
    final SnackBar snackBar = SnackBar(
      content: Text(
        "Total Distance: $totalDistance KM",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelSmall?.color,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      duration: const Duration(days: 1),
      action: SnackBarAction(
        label: "OK",
        onPressed: removeCurrentSnackBar,
      ),
      behavior: SnackBarBehavior.floating,
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void removeCurrentSnackBar() {
    return ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  Future<void> openBarModalBottomSheet(LatLng latLng) async {
    removeCurrentSnackBar();
    await showBarModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) {
        return SheetScreen(latLng: latLng);
      },
    );
    return Future<void>.value();
  }

  Future<void> getCurrentPosition() async {
    Position position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    position = await LocationService().getPosition(mounted: mounted).catchError(
      (Object error) {
        final SnackBar snackBar = SnackBar(
          content: Text(
            error.toString(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return position;
      },
    );
    await _controller.init(position);
    await animateCamera(_controller.currentPosition.value);
    return Future<void>.value();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await getCurrentPosition();
    return Future<void>.value();
  }
}
