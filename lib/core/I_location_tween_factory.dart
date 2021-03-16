import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animarker/infrastructure/anim_location_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'i_lat_lng.dart';

abstract class ILocationTweenFactory {
  ILocationTweenFactory({bool useRotation = true, Curve curve = Curves.linear});

  AnimLocationManagerImpl create({
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    Curve curve: Curves.linear,
    ILatLng begin,
    ILatLng end,
  });
}
