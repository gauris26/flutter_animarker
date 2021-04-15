import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_animarker/core/animarker_controller_description.dart';

import 'i_lat_lng.dart';
import 'i_location_dispatcher.dart';

typedef LatLngListener = void Function(ILatLng iLatLng);

typedef OnAnimCompleted = void Function(AnilocationTaskDescription description);

class AnilocationTaskDescription {
  final bool useRotation;
  final ILatLng begin;
  final ILatLng end;
  final Curve curve;
  final Duration duration;
  final Color rippleColor;
  final Duration rotationDuration;
  final Duration rippleDuration;
  final double rippleRadius;
  final double angleThreshold;
  final MarkerId markerId;
  final TickerProvider vsync;
  final LatLngListener? latLngListener;
  final OnAnimCompleted? onAnimCompleted;
  final RippleListener? onRippleAnimation;
  final ILocationDispatcher _dispatcher;


  const AnilocationTaskDescription({
    required this.vsync,
    required this.markerId,
    required this.onRippleAnimation,
    required ILocationDispatcher dispatcher,
    this.useRotation = true,
    this.begin = const ILatLng.empty(),
    this.end = const ILatLng.empty(),
    this.curve = Curves.linear,
    this.angleThreshold = 5.5,
    this.onAnimCompleted,
    this.rippleRadius = 0.5,
    this.latLngListener,
    this.rippleColor = Colors.red,
    this.duration = const Duration(milliseconds: 2000),
    this.rippleDuration = const Duration(milliseconds: 2000),
    this.rotationDuration = const Duration(milliseconds: 5000),
  }) : _dispatcher = dispatcher;

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
      end: end,
      begin: begin,
      curve: curve,
      markerId: markerId,
      vsync: description.vsync,
      duration: description.duration,
      angleThreshold: angleThreshold,
      latLngListener: latLngListener,
      onAnimCompleted: onAnimCompleted,
      rippleRadius: description.rippleRadius,
      rippleColor: description.rippleColor,
      useRotation: description.useRotation,
      rippleDuration: description.rippleDuration,
      rotationDuration: description.rotationDuration,
      onRippleAnimation: description.onRippleAnimation,
      dispatcher: ILocationDispatcher.queue(threshold: description.threshold),
    );
  }

  ILatLng get next => _dispatcher.next;
  int get length => _dispatcher.length;
  bool get isQueueEmpty => _dispatcher.isEmpty;
  bool get isQueueNotEmpty => _dispatcher.isNotEmpty;

  void push(ILatLng latLng) {
    if (latLng.isNotEmpty && _dispatcher.last != latLng) {
      _dispatcher.push(latLng);
    }
  }

  /*void  goTo(int index) {
    _dispatcher.goTo(_dispatcher.length - 1);
  }*/

  void dispose() {
    _dispatcher.dispose();
  }
}
