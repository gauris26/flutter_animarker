import 'dart:async';
import 'dart:math';

import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

const startPosition = LatLng(18.488213, -69.959186);

const CameraPosition _kSantoDomingo = CameraPosition(
  target: startPosition,
  zoom: 15,
);
class FlutterMapMarkerAnimationRealTimeExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() => _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationRealTimeExample> {
  LatLng startPosition = LatLng(18.488213, -69.959186);

  StreamSubscription<Position> positionStream;

  final Completer<GoogleMapController> _controller = Completer();

  double zoom = 1;

  Random random = Random();

  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  @override
  void initState() {
    super.initState();

    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 20,
    ).listen((Position position) async {
      double latitude = position.latitude;
      double longitude = position.longitude;

      setState(() {
        var markerId = MarkerId("MarkerId2");
        _markers[markerId] = RippleMarker(
          markerId: markerId,
          position: LatLng(latitude, longitude),
          onTap: () => print(markerId.value),
          ripple: ripple,
        );
      });

      /*await Future.delayed(Duration(milliseconds: min(1000, random.nextInt(1000) + 100)), () {
        setState(() {
          startPosition = LatLng(latitude + 0.001, longitude + 0.001);
        });
      });*/

      //Push new location changes
      CameraPosition cPosition = CameraPosition(
        zoom: 15,
        tilt: 0,
        bearing: 30,
        target: LatLng(latitude, longitude),
      );

      GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
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
                  onStopover: onStopover,
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

  Future<void> onStopover(LatLng latLng) async {



  }

  void onMapCreated(GoogleMapController controller) async {
    /*TODO*/
    //animarker.controller.getZoomLevel().then((value) => zoom = value/100);
  }

  @override
  void dispose() async {
    positionStream.cancel();
    GoogleMapController controller = await _controller.future;
    controller.dispose();
    super.dispose();
  }
}
