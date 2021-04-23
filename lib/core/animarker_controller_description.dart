import 'package:flutter/material.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
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
  final double angleThreshold;
  final int runExpressAfter;
  final bool isActiveTrip;
  final Color rippleColor;
  final double rippleRadius;
  final Curve curve;
  final Duration duration;
  final Duration rippleDuration;

  const AnimarkerControllerDescription({
    required this.vsync,
    required this.onStopover,
    required this.useRotation,
    required this.onMarkerAnimation,
    this.angleThreshold = 1.5,
    this.isActiveTrip = true,
    this.runExpressAfter = 10,
    this.rippleRadius = 0.5,
    this.onRippleAnimation,
    this.curve = Curves.linear,
    this.rippleColor = Colors.red,
    this.duration = const Duration(milliseconds: 2500),
    this.rippleDuration = const Duration(milliseconds: 2000),
  });

  factory AnimarkerControllerDescription.animarker(
    Animarker animarker, {
    required TickerProvider vsync,
    OnStopover? onStopover,
    RippleListener? onRippleAnimation,
    MarkerListener? onMarkerAnimation,
  }) =>
      AnimarkerControllerDescription(
        angleThreshold: animarker.angleThreshold,
        curve: animarker.curve,
        duration: animarker.duration,
        isActiveTrip: animarker.isActiveTrip,
        onMarkerAnimation: onMarkerAnimation,
        onRippleAnimation: onRippleAnimation,
        onStopover: onStopover,
        rippleColor: animarker.rippleColor,
        rippleDuration: animarker.rippleDuration,
        rippleRadius: animarker.rippleRadius,
        runExpressAfter: animarker.runExpressAfter,
        useRotation: animarker.useRotation,
        vsync: vsync,
      );
}
