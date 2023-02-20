import "dart:async";
import "dart:io";

import "package:after_layout/after_layout.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:geocoding/geocoding.dart";
import "package:get/get.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:google_maps_integration/controller/sheet_controller.dart";
import "package:place_picker/place_picker.dart";

class SheetScreen extends StatefulWidget {
  const SheetScreen({required this.latLng, super.key});

  final LatLng latLng;

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen>
    with AfterLayoutMixin<SheetScreen> {
  final SheetController _controller = Get.put(
    SheetController(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          return FutureBuilder<dynamic>(
            future: _controller.futuresList.value,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error} occurred"),
                  );
                } else if (snapshot.hasData) {
                  final List<dynamic> snapshotList = snapshot.data;
                  final Placemark mark = snapshotList[0] ?? Placemark();
                  final List<String> list = snapshotList[1] as List<String>;
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[placeMark(mark), gridView(list)],
                    ),
                  );
                }
              }
              return Center(
                child: Platform.isIOS
                    ? const CupertinoActivityIndicator()
                    : Platform.isAndroid
                        ? const CircularProgressIndicator()
                        : const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }

  Widget placeMark(Placemark mark) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Name : ${mark.name}"),
          Text("Street : ${mark.street}"),
          Text("Administrative Area : ${mark.administrativeArea}"),
          Text("Locality : ${mark.locality}"),
          Text("Thoroughfare : ${mark.thoroughfare}"),
          Text("Postal Code : ${mark.postalCode}"),
          Text("ISO Country Code : ${mark.isoCountryCode}"),
          Text("Country : ${mark.country}"),
        ],
      ),
    );
  }

  Widget gridView(List<String> list) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Image.network(list[index]);
      },
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await _controller.updateFuture(widget.latLng);
    return Future<void>.value();
  }
}
