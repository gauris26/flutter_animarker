// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Package imports:

import 'animarker_controller_description.dart';

abstract class IAnimarkerController {
  AnimarkerControllerDescription get description;
  double get radiusValue;
  Color get colorValue;
  double get zoomScale;
  bool get isActiveTrip;
  AnimationController get rippleController;

  set isActiveTrip(bool active);

  void pushMarker(Marker marker);

  void updateZoomLevel(double density, double radius, double zoom);

  void dispose();
}
