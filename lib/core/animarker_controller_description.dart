import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'i_location_dispatcher.dart';

typedef RippleListener = void Function(Circle circle);
typedef MarkerListener = void Function(Marker marker);
typedef OnStopover = Future<void> Function(LatLng latLng);

class AnimarkerControllerDescription {
  final RippleListener? onRippleAnimation;
  final MarkerListener? onMarkerAnimation;
  final OnStopover? onStopover;
  final ILocationDispatcher dispatcher;
  final TickerProvider vsync;
  final bool useRotation;
  final int purgeLimit;
  final Color rippleColor;
  final Duration duration;
  final Duration rotationDuration;
  final Duration rippleDuration;

  bool get isQueueEmpty => dispatcher.isEmpty;
  bool get isQueueNotEmpty => dispatcher.isNotEmpty;

  const AnimarkerControllerDescription({
    this.onRippleAnimation,
    required this.vsync,
    required this.onMarkerAnimation,
    required this.useRotation,
    required this.dispatcher,
    required this.onStopover,
    this.purgeLimit = 10,
    this.rippleColor = Colors.red,
    this.duration = const Duration(milliseconds: 2500),
    this.rotationDuration = const Duration(milliseconds: 5000),
    this.rippleDuration = const Duration(milliseconds: 2000),
  });
}
