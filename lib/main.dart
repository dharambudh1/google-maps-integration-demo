import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:google_maps_flutter_android/google_maps_flutter_android.dart";
import "package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart";
import "package:google_maps_integration/screen/home_screen.dart";
import "package:keyboard_dismisser/keyboard_dismisser.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GoogleMapsFlutterPlatform instance = GoogleMapsFlutterPlatform.instance;
  if (instance is GoogleMapsFlutterAndroid) {
    instance.useAndroidViewSurface = true;
  }
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: GetMaterialApp(
        title: "Google Maps Demo",
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        enableLog: false,
      ),
    );
  }
}
