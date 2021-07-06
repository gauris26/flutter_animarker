import 'dart:async';
import 'dart:math';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'extensions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

const startPosition = LatLng(18.488213, -69.959186);

const CameraPosition _kSantoDomingo = CameraPosition(
  target: startPosition,
  zoom: 15,
);

class FlutterMapMarkerAnimationRealTimeExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() =>
      _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationRealTimeExample> {
  LatLng startPosition = LatLng(18.488213, -69.959186);
  LatLng startPosition2 = LatLng(18.488213, -69.959186);

  late final StreamSubscription<Position> positionStream;
  BitmapDescriptor pinLocationIcon = BitmapDescriptor.defaultMarker;

  final Completer<GoogleMapController> _controller = Completer();

  double zoom = 15;

  bool isActiveTrip = true;

  bool useRotation = true;

  bool ripple = true;

  Random random = Random();

  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/pin_marker_1.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });

    super.initState();

    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 20,
    ).listen((Position p) async {
      setState(() {
        var markerId = MarkerId('MarkerId3');
        _markers[markerId] = RippleMarker(
          markerId: markerId,
          icon: pinLocationIcon,
          position: LatLng(p.latitude, p.longitude),
          ripple: ripple,
        );
      });

      await Future.delayed(
          Duration(milliseconds: min(1000, random.nextInt(5000))), () {
        setState(() {
          startPosition = LatLng(p.latitude + 0.001, p.longitude + 0.001);
        });
      });

      await Future.delayed(
          Duration(milliseconds: min(1000, random.nextInt(1000) + 100)), () {
        setState(() {
          startPosition2 = LatLng(p.latitude - 0.01, p.longitude - 0.002);
        });
      });
    });
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
          child: Builder(builder: (context) {
            return Stack(
              children: [
                Animarker(
                  mapId: _controller.future.then<int>((value) => value.mapId),
                  isActiveTrip: isActiveTrip,
                  rippleRadius: 0.25,
                  useRotation: useRotation,
                  zoom: zoom,
                  duration: Duration(milliseconds: 2000),
                  onStopover: onStopover,
                  markers: <Marker>{
                    //Avoid sent duplicate MarkerId
                    ..._markers.values.toSet(),
                    /*RippleMarker(
                      icon: BitmapDescriptor.defaultMarker,
                      markerId: MarkerId('MarkerId1'),
                      position: startPosition,
                      ripple: false,
                    ),
                    Marker(
                      markerId: MarkerId('MarkerId2'),
                      position: startPosition2,
                    ),*/
                  },
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kSantoDomingo,
                    onMapCreated: (controller) =>
                        _controller.complete(controller),
                    onCameraMove: (ca) => setState(() => zoom = ca.zoom),
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.85),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: (ripple ? Colors.red : Colors.blue).buttonStyle,
                        onPressed: () => setState(() => ripple = !ripple),
                        child: Text(ripple ? 'Stop Ripple' : 'Start Ripple',  style: TextStyle(fontSize: 12),),
                      ),
                      ElevatedButton(
                        style: (useRotation ? Colors.red : Colors.blue)
                            .buttonStyle,
                        onPressed: () =>
                            setState(() => useRotation = !useRotation),
                        child: Text(
                            useRotation ? 'Stop Rotation' : 'Start Rotation',  style: TextStyle(fontSize: 12),),
                      ),
                      ElevatedButton(
                        style: (isActiveTrip ? Colors.red : Colors.blue)
                            .buttonStyle,
                        onPressed: () =>
                            setState(() => isActiveTrip = !isActiveTrip),
                        child: Text(isActiveTrip ? 'Stop trip' : 'Start trip', style: TextStyle(fontSize: 12),),
                      ),
                      ElevatedButton(
                        style: (isActiveTrip ? Colors.red : Colors.blue)
                            .buttonStyle,
                        onPressed: () =>
                            setState(() => _markers.clear()),
                        child: Text('Clear marker', style: TextStyle(fontSize: 12),),
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
  }

  @override
  Future<void> dispose() async {
    await positionStream.cancel();
    var controller = await _controller.future;
    controller.dispose();
    super.dispose();
  }
}
