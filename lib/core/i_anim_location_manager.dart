// Project imports:
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'i_animation_mode.dart';
import 'package:flutter_animarker/infrastructure/anim_location_manager.dart';
import 'i_lat_lng.dart';

typedef LatLngListener = void Function(ILatLng iLatLng);

typedef OnAnimCompleted = void Function(IAnimationMode anim);


abstract class IAnimLocationManager implements IAnimationMode {

  ILatLng get begin;
  set begin (ILatLng value);

  ILatLng get end;
  set end (ILatLng value);

  ILatLng get value;

  bool get isAnimating;

  bool get isDismissed;

  bool get isCompleted;

  factory IAnimLocationManager.create({
    bool useRotation,
    ILatLng begin,
    ILatLng end,
    Curve curve,
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    Duration duration,
    Duration rotationDuration
  }) = AnimLocationManagerImpl;

  void dispose();

  void forward(ILatLng from);
}
