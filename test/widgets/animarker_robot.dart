import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AnimarkerRobot {
  Animarker getNewAnimarker(
    Key? key,
    Completer<GoogleMapController> completer,
    Set<Marker> markers,
    CameraPosition initialCameraPosition,
  ) =>
      Animarker(
        key: key,
        mapId: completer.future.then<int>((value) => value.mapId),
        isActiveTrip: true,
        radius: 0.08,
        zoom: 15.0,
        performanceMode: PerformanceMode.better,
        duration: Duration(milliseconds: 2000),
        onStopover: (latLng) async {},
        markers: markers,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialCameraPosition,
          onMapCreated: (controller) => completer.complete(controller),
          //onCameraMove: (ca) => setState(() => zoom = ca.zoom),
        ),
      );
}
