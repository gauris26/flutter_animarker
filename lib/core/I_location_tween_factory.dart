import 'package:flutter/animation.dart';
import 'package:flutter_animarker/anims/location_tween.dart';
import 'i_lat_lng.dart';

abstract class ILocationTweenFactory {

  ILocationTweenFactory({bool useRotation = true, Curve curve = Curves.linear});

  LocationTween create({ILatLng begin, ILatLng end});
}
