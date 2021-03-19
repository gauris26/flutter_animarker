import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef RippleListener = void Function(Circle circle);
typedef MarkerListener = void Function(Marker marker);
typedef OnStopover = Future<void> Function(LatLng latLng);

abstract class IAnimarkerController {
  double get radiusValue;
  Color get colorValue;
  double get zoomScale;
  bool get isActiveTrip;
  bool get isQueueEmpty;
  bool get isQueueNotEmpty;
  AnimationController get rippleController;

  set isActiveTrip(bool active);
  set onRippleAnimation(RippleListener r);

  RippleListener get onRippleAnimation;
  MarkerListener get onMarkerAnimation;
  OnStopover get onStopover;

  void pushMarker(Marker marker);

  void updateZoomLevel(double density, double radius, double zoom);

  void dispose();
}