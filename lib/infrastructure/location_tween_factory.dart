import 'package:flutter/cupertino.dart';
import 'package:flutter_animarker/core/I_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/infrastructure/anim_location_manager.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationTweenFactoryImpl implements ILocationTweenFactory {
  late final bool useRotation;

  LocationTweenFactoryImpl({this.useRotation = true});

  @override
  AnimLocationManagerImpl create({
    required MarkerId markerId,
    required TickerProvider vsync,
    required OnAnimCompleted onAnimCompleted,
    required LatLngListener latLngListener,
    Curve curve: Curves.linear,
    ILatLng begin = const LatLngInfo.empty(),
    ILatLng end = const LatLngInfo.empty(),
  }) =>
      AnimLocationManagerImpl(
        markerId: markerId,
        vsync: vsync,
        begin: begin,
        end: end,
        onAnimCompleted: onAnimCompleted,
        latLngListener: latLngListener,
        useRotation: useRotation,
      );
}
