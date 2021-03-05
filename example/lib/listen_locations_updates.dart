import 'dart:async';

import 'extensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/anims/angle_tween.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/animation_marker_controller.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

const startPosition = LatLng(18.488213, -69.959186);

class FlutterMapMarkerAnimationRealTimeExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() => _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState extends State<FlutterMapMarkerAnimationRealTimeExample>
    with TickerProviderStateMixin {
  //Markers collection, proper way
  final Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();
  final Map<CircleId, Circle> _circles = Map<CircleId, Circle>();

  var sourceId = MarkerId("SourcePin");

  var circleId = CircleId("CircleId");

  var _animarkerController = AnimarkerController();

  StreamSubscription<Position> positionStream;

  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kSantoDomingo = CameraPosition(
    target: startPosition,
    zoom: 15,
  );

  AnimationController _animationController;
  AnimationController _rippleAnimationController;
  Tween<double> radiusTween;
  Tween<double> borderWidthTween;
  ColorTween colorTween;
  Animation<double> radiusAnimation;
  Animation<Color> colorAnimation;
  AnimationStatus status;
  //New Animation Model
  LocationTween _locationTween;
  AngleTween _angleTween;
  Animation<ILatLng> _locationAnimation;
  Animation<double> _angleAnimation;
  double zoom = 1;

  @override
  void initState() {
    super.initState();
    //ColorTween
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.future.then(
              (value) => value.animateCamera(_locationAnimation?.value?.toLatLng?.cameraPosition));
        }
      });

    _rippleAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 2000));

    radiusTween = Tween<double>(begin: 0, end: 160);

    radiusAnimation = radiusTween
        .animate(CurvedAnimation(curve: Curves.easeOutSine, parent: _rippleAnimationController))
          ..addStatusListener((AnimationStatus listener) {
            if (_rippleAnimationController.status == AnimationStatus.completed &&
                !_rippleAnimationController.isDismissed) {
              Future.delayed(Duration(milliseconds: 400), () {
                _rippleAnimationController.forward(from: 0);
              });
            }
          })
          ..addListener(() {
            setState(() {
              for (int wave = 3; wave >= 0; wave--) {
                var circleId = CircleId("CircleId->$wave");
                Circle circle = Circle(
                  circleId: circleId,
                  center: _locationAnimation.value.toLatLng,
                  radius: (radiusAnimation.value * wave) * zoom,
                  fillColor: colorAnimation.value,
                  strokeWidth: 1,
                  strokeColor:colorAnimation.value.withOpacity((colorAnimation.value.opacity+0.03).clamp(0.0, 1.0)),
                );

                _circles[circleId] = circle;
              }
            });
          });

    colorAnimation = ColorTween(begin: Colors.red.withOpacity(0.6), end: Colors.red.withOpacity(0.0))
        .chain(CurveTween(curve: Curves.ease))
        .animate(_rippleAnimationController);

    GoogleMapsFlutterPlatform.instance;
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 20,
    ).listen((Position position) async {
      double latitude = position.latitude;
      double longitude = position.longitude;

      _locationTween.begin = _locationTween.end;
      _locationTween.end =
          LatLngInfo(latitude, longitude, sourceId.value, _locationTween.end.bearing);

      _angleTween.begin = _angleTween.end;
      _angleTween.end = _locationTween.end.bearing;

      try {
        _animationController.reset();
        await _animationController.forward().orCancel;
      } on TickerCanceled {
        _animationController.forward(from: _animationController.value);
      }

      //Push new location changes
      CameraPosition cPosition = CameraPosition(
        zoom: 15,
        tilt: 0,
        bearing: 30,
        target: LatLng(latitude, longitude),
      );

      _controller.future
          .then((value) => value.animateCamera(CameraUpdate.newCameraPosition(cPosition)));

      /*_controller.future.then((map) => map.getScreenCoordinate(delta.to.toLatLng)).then(
            (value) => setState(
              () {
            if(delta.markerId == source2Id.value)
              _markerScreenOffset = Offset(value.x.toDouble(), value.y.toDouble()) ;
          },
        ),
      );*/
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
                GoogleMap(
                  mapType: MapType.normal,
                  markers: Set<Marker>.of(_markers.values),
                  initialCameraPosition: _kSantoDomingo,
                  onMapCreated: onMapCreated,
                  circles: Set<Circle>.of(_circles.values),
                  onCameraMove: (ca){
                    print("${ca.zoom}");
                    zoom = ca.zoom/100;
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {

    controller.getZoomLevel().then((value) => zoom = value/100);

    _controller.complete(controller);

    _locationTween = LocationTween(
        begin: startPosition.toLatLngInfo(sourceId.value),
        end: startPosition.toLatLngInfo(sourceId.value));

    _angleTween = AngleTween(begin: 0, end: 0);

    _angleAnimation = _angleTween.animate(_animationController);

    _locationAnimation = _locationTween.animate(
      CurvedAnimation(
          curve: Curves.linearToEaseOut, reverseCurve: Curves.linear, parent: _animationController),
    )..addListener(() {
        setState(() {
          var markerId = MarkerId(_locationAnimation.value.markerId);

          Marker marker = Marker(
            markerId: markerId,
            rotation: _angleAnimation.value,
            position: _locationAnimation.value.toLatLng,
          );

          //Update the marker with animation
          _markers[markerId] = marker;
        });
      });

    _animationController.forward();
    _rippleAnimationController.forward();
  }

  @override
  void dispose() {
    _animarkerController.close();
    positionStream.cancel();
    _animationController.dispose();
    _rippleAnimationController.dispose();
    super.dispose();
  }
}
