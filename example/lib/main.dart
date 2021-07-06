import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'listen_locations_updates.dart';

//Setting dummies values
const kStartPosition = LatLng(18.488213, -69.959186);
const kSantoDomingo = CameraPosition(target: kStartPosition, zoom: 15);
const kMarkerId = MarkerId('MarkerId1');
const kDuration = Duration(seconds: 2);
const kLocations = [
  kStartPosition,
  LatLng(18.488101, -69.957995),
  LatLng(18.489210, -69.952459),
  LatLng(18.487307, -69.952759),
  LatLng(18.487308, -69.952759),
];

class SimpleMarkerAnimationExample extends StatefulWidget {
  @override
  SimpleMarkerAnimationExampleState createState() =>
      SimpleMarkerAnimationExampleState();
}

class SimpleMarkerAnimationExampleState
    extends State<SimpleMarkerAnimationExample> {
  final markers = <MarkerId, Marker>{};
  final controller = Completer<GoogleMapController>();
  final stream = Stream.periodic(kDuration, (count) => kLocations[count])
      .take(kLocations.length);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Markers Animation Example',
      home: Animarker(
        curve: Curves.bounceOut,
        rippleRadius: 0.2,
        useRotation: false,
        duration: Duration(milliseconds: 2300),
        mapId: controller.future
            .then<int>((value) => value.mapId), //Grab Google Map Id
        markers: markers.values.toSet(),
        child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: kSantoDomingo,
            onMapCreated: (gController) {
              stream.forEach((value) => newLocationUpdate(value));
              controller.complete(gController);
              //Complete the future GoogleMapController
            }),
      ),
    );
  }

  void newLocationUpdate(LatLng latLng) {
    var marker = RippleMarker(
        markerId: kMarkerId,
        position: latLng,
        ripple: true,
        onTap: () {
          print('Tapped! $latLng');
        });
    setState(() => markers[kMarkerId] = marker);
  }
}

void main() {
  runApp(FlutterMapMarkerAnimationRealTimeExample());
}
