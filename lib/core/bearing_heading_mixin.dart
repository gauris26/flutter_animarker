import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

mixin BearingHeadingMixin  on Tween<ILatLng> {

  double performBearing(ILatLng begin, ILatLng end) {

    if (begin == end) return 0;

    var bearing = SphericalUtil.getBearing(begin, end);

    if (bearing.isNaN) bearing = 0;

    return bearing;
  }
}