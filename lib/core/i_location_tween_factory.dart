// Flutter imports:
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'i_anim_location_manager.dart';
import 'i_lat_lng.dart';
import 'package:flutter_animarker/infrastructure/location_tween_factory.dart';

abstract class ILocationTweenFactory {

  const factory ILocationTweenFactory.factory({bool useRotation}) = LocationTweenFactoryImpl;

  IAnimLocationManager create({
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    Curve curve = Curves.linear,
    ILatLng begin,
    ILatLng end,
  });


}
