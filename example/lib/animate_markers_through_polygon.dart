/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/animation_marker_controller.dart';
import 'package:flutter_animarker/models/lat_lng_delta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'extensions.dart';

final startPosition = LatLngInfo(18.488213, -69.959186);

//Run over the polygon position
final polygon = <LatLngInfo>[
  startPosition,
  LatLngInfo(18.489338, -69.947091),
  LatLngInfo(18.495351, -69.949366),
  LatLngInfo(18.497477, -69.947596),
  LatLngInfo(18.498932, -69.948615),
  LatLngInfo(18.498373, -69.958779),
  LatLngInfo(18.488600, -69.959574),
];

class FlutterMapMarkerAnimationExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() =>
      _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationExample> {
  //Markers collection, proper way
  final _markers = Map<MarkerId, Marker>();

  MarkerId sourceId = MarkerId("SourcePin");

  final _latLngStream = AnimarkerController();

  StreamSubscription<LatLngDelta> subscription;

  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kSantoDomingo = CameraPosition(
    target: startPosition.toLatLng,
    zoom: 15,
  );

  @override
  void initState() {
    subscription =
        _latLngStream.getAnimatedPosition("SourcePin").listen((LatLngDelta delta) {

      LatLng from = delta.from.toLatLng;
      print("To: -> ${from.toJson()}");
      LatLng to = delta.to.toLatLng;
      print("From: -> ${to.toJson()}");
      double angle = delta.rotation;
      print("Angle: -> $angle");
      //Update the animated marker
      setState(() {
        Marker sourceMarker = Marker(
          markerId: sourceId,
          rotation: delta.rotation,
          position: LatLng(
            delta.from.latitude,
            delta.from.longitude,
          ),
        );
        _markers[sourceId] = sourceMarker;
      });

      if (polygon.isNotEmpty) {
        //Pop the last position
        _latLngStream.addLatLng(polygon.removeLast());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Markers Animation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: SafeArea(
          child: GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.of(_markers.values),
            initialCameraPosition: _kSantoDomingo,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

              setState(() {
                Marker sourceMarker = Marker(
                  markerId: sourceId,
                  position: startPosition.toLatLng,
                );
                _markers[sourceId] = sourceMarker;
              });

              _latLngStream.addLatLng(startPosition);
              //Add second position to start position over
              Future.delayed(const Duration(milliseconds: 3000), () {
                _latLngStream.addLatLng(polygon.removeLast());
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
*/
