import 'dart:async';
import 'dart:math';

import 'package:flutter_animarker/helpers/math_util.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
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
  LatLng startPosition2 = LatLng(18.488213, -69.959186);

  StreamSubscription<Position> positionStream;

  final Completer<GoogleMapController> _controller = Completer();

  double zoom = 15;

  bool isActiveTrip = true;

  Random random = new Random();

  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  @override
  void initState() {
    super.initState();

    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 20,
    ).listen((Position p) async {
      setState(() {
        var markerId = MarkerId("MarkerId2");
        _markers[markerId] = RippleMarker(
          markerId: markerId,
          position: LatLng(p.latitude, p.longitude),
          ripple: ripple,
        );
      });

      await Future.delayed(Duration(milliseconds: min(1000, random.nextInt(1000) + 100)), () {
        setState(() {
          startPosition = LatLng(p.latitude + 0.001, p.longitude + 0.001);
        });
      });

      await Future.delayed(Duration(milliseconds: min(1000, random.nextInt(1000) + 100)), () {
        setState(() {
          startPosition2 = LatLng(p.latitude - 0.01, p.longitude - 0.002);
        });
      });
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
                  isActiveTrip: isActiveTrip,
                  radius: 0.08,
                  zoom: zoom,
                  performanceMode: PerformanceMode.better,
                  duration: Duration(milliseconds: 2000),
                  onStopover: onStopover,
                  markers: <Marker>{
                    //Avoid sent duplicate MarkerId
                    ..._markers.values.toSet(),
                    RippleMarker(
                      markerId: MarkerId("MarkerId1"),
                      position: startPosition,
                      ripple: true,
                    ),
                    RippleMarker(
                      markerId: MarkerId("MarkerId3"),
                      position: startPosition2,
                      ripple: true,
                    )
                  },
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kSantoDomingo,
                    onMapCreated: (controller) => _controller.complete(controller),
                    onCameraMove: (ca) => setState(() => zoom = ca.zoom),
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.85),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                ripple ? Colors.red : Colors.blue)),
                        onPressed: () => setState(() {
                          ripple = !ripple;
                        }),
                        child: Text(ripple ? "End Ripple" : "Active Ripple"),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                isActiveTrip ? Colors.red : Colors.blue)),
                        onPressed: () => setState(() {
                          isActiveTrip = !isActiveTrip;
                        }),
                        child: Text(isActiveTrip ? "End trip" : "Active trip"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> onStopover(LatLng latLng) async {
    if (!_controller.isCompleted) return;

    GoogleMapController controller = await _controller.future;
    double zoom = await controller.getZoomLevel();

    CameraPosition camPosition = CameraPosition(
      zoom: zoom,
      tilt: 0,
      bearing: 30,
      target: latLng,
    );

    await controller.animateCamera(CameraUpdate.newCameraPosition(camPosition));
  }

  @override
  void dispose() async {
    positionStream.cancel();
    GoogleMapController controller = await _controller.future;
    controller.dispose();
    super.dispose();
  }
}
