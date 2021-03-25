import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';

import 'i_animation_mode.dart';
import 'i_lat_lng.dart';

typedef LatLngListener = void Function(ILatLng iLatLng);

typedef OnAnimCompleted = void Function(IAnimationMode anim);

class AnilocationTaskDescription {
  final useRotation;
  final ILatLng begin;
  final ILatLng end;
  final Curve curve;
  final Duration duration;
  final Duration rotationDuration;
  final double angleThreshold;
  final MarkerId markerId;
  final TickerProvider vsync;
  final LatLngListener? latLngListener;
  final OnAnimCompleted? onAnimCompleted;

  Duration get maxDuration => rotationDuration + duration;
  double get locationInterval =>
      (duration.inMilliseconds / maxDuration.inMilliseconds).clamp(0.0, 1.0).toDouble();

  const AnilocationTaskDescription({
    required this.markerId,
    required this.vsync,
    this.useRotation = true,
    this.begin = const ILatLng.empty(),
    this.end = const ILatLng.empty(),
    this.curve = Curves.linear,
    this.angleThreshold = 5.5,
    this.onAnimCompleted,
    this.latLngListener,
    this.duration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 5000),
  });

  factory AnilocationTaskDescription.animarker({
    required AnimarkerControllerDescription description,
    required MarkerId markerId,
    OnAnimCompleted? onAnimCompleted,
    LatLngListener? latLngListener,
    ILatLng begin = const ILatLng.empty(),
    ILatLng end = const ILatLng.empty(),
    Curve curve = Curves.linear,
    double angleThreshold = 5.5,
  }) {
    return AnilocationTaskDescription(
      markerId: markerId,
      onAnimCompleted: onAnimCompleted,
      begin: begin,
      end: end,
      curve: curve,
      angleThreshold: angleThreshold,
      latLngListener: latLngListener,
      vsync: description.vsync,
      useRotation: description.useRotation,
      duration: description.duration,
      rotationDuration: description.rotationDuration,
    );
  }
}
