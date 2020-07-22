import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/lat_lng_interpolation.dart';
import 'package:flutter_animarker/models/lat_lng_delta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const startPosition = LatLng(18.488213, -69.959186);

class FlutterMapMarkerAnimationRealTimeExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() =>
      _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationRealTimeExample> {
  //Markers collection, proper way
  final Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  MarkerId sourceId = MarkerId("SourcePin");

  LatLngInterpolationStream _latLngStream = LatLngInterpolationStream(
    movementDuration: Duration(milliseconds: 2000),
  );

  StreamSubscription<LatLngDelta> subscription;

  StreamSubscription<Position> positionStream;

  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kSantoDomingo = CameraPosition(
    target: startPosition,
    zoom: 15,
  );

  @override
  void initState() {
    subscription =
        _latLngStream.getLatLngInterpolation().listen((LatLngDelta delta) {
      //Update the marker with animation
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
    });

    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      double latitude = position.latitude;
      double longitude = position.longitude;
      //Push new location changes
      _latLngStream.addLatLng(LatLng(latitude, longitude));
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
                  position: startPosition,
                );
                _markers[sourceId] = sourceMarker;
              });

              _latLngStream.addLatLng(startPosition);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    positionStream.cancel();
    super.dispose();
  }
}
