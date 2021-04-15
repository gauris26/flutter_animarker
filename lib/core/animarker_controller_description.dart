import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

typedef RippleListener = void Function(Circle circle);
typedef MarkerListener = void Function(Marker marker, bool isStopover);
typedef OnStopover = Future<void> Function(LatLng latLng);

class AnimarkerControllerDescription {
  final RippleListener? onRippleAnimation;
  final MarkerListener? onMarkerAnimation;
  final OnStopover? onStopover;
  final TickerProvider vsync;
  final bool useRotation;
  final double threshold;
  final int purgeLimit;
  final Color rippleColor;
  final double rippleRadius;
  final Curve curve;
  final Duration duration;
  final Duration rotationDuration;
  final Duration rippleDuration;

  const AnimarkerControllerDescription({
    required this.vsync,
    required this.onStopover,
    required this.useRotation,
    required this.onMarkerAnimation,
    this.threshold = 1.5,
    this.purgeLimit = 10,
    this.rippleRadius = 0.5,
    this.onRippleAnimation,
    this.curve = Curves.linear,
    this.rippleColor = Colors.red,
    this.duration = const Duration(milliseconds: 2500),
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 5000),
  });
}
