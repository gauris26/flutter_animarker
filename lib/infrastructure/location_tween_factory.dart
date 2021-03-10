import 'package:flutter_animarker/anims/location_tween.dart';
import 'package:flutter_animarker/core/I_location_tween_factory.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';

class LocationTweenFactoryImpl implements ILocationTweenFactory {
  late bool useRotation;

  LocationTweenFactoryImpl({this.useRotation = true});

  @override
  LocationTween create({
    ILatLng begin = const LatLngInfo.empty(),
    ILatLng end = const LatLngInfo.empty(),
  }) =>
      LocationTween(begin: begin, end: end, isBearing: useRotation);
}
