import 'dart:async';

import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

const startPosition = LatLng(18.488213, -69.959186);

class FlutterMapMarkerAnimationRealTimeExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() => _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationRealTimeExample> {
  LatLng startPosition = LatLng(18.488213, -69.959186);

  StreamSubscription<Position> positionStream;

  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kSantoDomingo;

  double zoom = 1;

  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  @override
  void initState() {
    super.initState();

    _kSantoDomingo = CameraPosition(
      target: startPosition,
      zoom: 15,
    );

    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 20,
    ).listen((Position position) async {
      double latitude = position.latitude;
      double longitude = position.longitude;

      setState(() {
        var markerId = MarkerId("MarkerId2");
        _markers[markerId] = RippleMarker(
          markerId: MarkerId("MarkerId2"),
          position: LatLng(latitude, longitude),
          ripple: ripple,
        );
      });

      //Push new location changes
      CameraPosition cPosition = CameraPosition(
        zoom: 16,
        tilt: 0,
        bearing: 30,
        target: LatLng(latitude, longitude),
      );

      _controller.future
          .then((value) => value.animateCamera(CameraUpdate.newCameraPosition(cPosition)));
    });
  }

  bool ripple = true;
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
          child: Builder(builder: (context) {
            return Stack(
              children: [
                Animarker(
                  controller: _controller.future,
                  performanceMode: PerformanceMode.better,
                  markers: <Marker>{
                    //Avoid sent duplicate MarkerId
                    ..._markers.values.toSet(),
                    /*RippleMarker(
                      markerId: MarkerId("MarkerId1"),
                      position: startPosition,
                      ripple: true,
                    )*/
                  },
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kSantoDomingo,
                    onMapCreated: (controller) => _controller.complete(controller),
                    onCameraMove: (ca) {
                      zoom = ca.zoom / 100;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.9),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(ripple ? Colors.red : Colors.blue)),
                      onPressed: () => setState(() {
                            ripple = !ripple;
                          }),
                      child: Text("Ripple: $ripple")),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    /*TODO*/
    //animarker.controller.getZoomLevel().then((value) => zoom = value/100);
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }
}
