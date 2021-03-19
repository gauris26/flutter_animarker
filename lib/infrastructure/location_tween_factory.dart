// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter_animarker/core/i_anim_location_manager.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:flutter_animarker/core/i_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';

class LocationTweenFactoryImpl implements ILocationTweenFactory {
  final bool useRotation;

  const LocationTweenFactoryImpl({this.useRotation = true});

  @override
  IAnimLocationManager create({
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    Curve curve = Curves.linear,
    ILatLng begin = const ILatLng.empty(),
    ILatLng end = const ILatLng.empty(),
  }) =>
      IAnimLocationManager.create(
        markerId: markerId,
        vsync: vsync,
        begin: begin,
        end: end,
        curve: curve,
        onAnimCompleted: onAnimCompleted,
        latLngListener: latLngListener,
        useRotation: useRotation,
      );
}
