import 'package:flutter/animation.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';

abstract class IAnimationMode {
  void animateTo(ILatLng iLatLng);

  void animatePoints(List<ILatLng> list, {ILatLng last, Curve curve});
}