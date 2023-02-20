# Google Maps Integration Demo

## Features:
- Location permission & service handling,
- Custom markers for current, source & destination locations,
- Source to destination road path-finding & total distance (in KM) calculating,
- It is available in 6 different map styles [Standard, Silver, Retro, Dark, Night, Aubergine],
- It has beautiful & smooth animations as well.

## Installation Steps:
- I did make changes in a few pub libraries due to the below-mentioned issues:
- Issue #1: Location service requests are getting fail on older android devices due to the obsolete or deprecated location library used in the package.<br> Resolution #1: Goto: /flutter/.pub-cache/hosted/pub.dartlang.org/location-4.4.0/android/build.gradle
comment line no 50: api 'com.google.android.gms:play-services-location:16.+'
& replace with code: api 'com.google.android.gms:play-services-location:21.0.1'
- Issue #2: There is no back button on Place Picker Screen for iOS devices because the place_picker library intentionally hides that back button from the app bar.<br>Resolution #2: Goto: /flutter/.pub-cache/hosted/pub.dartlang.org/place_picker-0.10.0/lib/widgets/place_picker.dart
comment line no 149: automaticallyImplyLeading: false
& replace with code: automaticallyImplyLeading: true

## Important:
- Do not forget to mention your Google API Key on AndroidManifest.xml, AppDelegate.swift, Info.plist & key_constant.dart.

## Preview
![alt text](https://i.postimg.cc/j2qs8jn1/imgonline-com-ua-twotoone-y-Iw-H2n-GFKKe46k-P.png "img")
