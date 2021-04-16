import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AnimarkerRobot {
  late final WidgetTester tester;
  int counter = 0;
  AnimarkerRobot(this.tester);

  Future<Animarker> newBuild(
    Key? key,
    Marker newMarker,
    CameraPosition cameraPosition,
    bool useRotation,
  ) async {
    final completer = Completer<GoogleMapController>();
    var animarker = getNewAnimarker(key, completer, <Marker>{newMarker}, cameraPosition, useRotation);

    debugPrint('Pumping ${++counter}');

    await tester.pumpWidget(MaterialApp(home: animarker));

    return animarker;
  }

  Animarker getNewAnimarker(
    Key? key,
    Completer<GoogleMapController> completer,
    Set<Marker> markers,
    CameraPosition initialCameraPosition,
    bool useRotation,
  ) =>
      Animarker(
        key: key,
        mapId: completer.future.then<int>((value) => value.mapId),
        isActiveTrip: true,
        rippleRadius: 0.08,
        useRotation: useRotation,
        zoom: 15.0,
        duration: Duration(milliseconds: 2000),
        onStopover: (latLng) async {},
        markers: markers,
        curve: Curves.linear,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialCameraPosition,
          onMapCreated: (controller) => completer.complete(controller),
          //onCameraMove: (ca) => setState(() => zoom = ca.zoom),
        ),
      );
}
