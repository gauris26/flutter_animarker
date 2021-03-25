// Flutter imports:

import 'package:flutter_animarker/models/lat_lng_info.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Package imports:


abstract class  ILatLng {
  final double latitude = 0;
  final double longitude = 0;
  final double bearing = 0;
  final double mapScale = 1.0;
  final MarkerId markerId = const MarkerId('');
  final bool isStopover = false;
  final bool ripple = false;
  final bool isEmpty = false;


  const factory ILatLng.empty() = LatLngInfo.empty;

  const factory ILatLng.point(double latitude, double longitude) = LatLngInfo.point;

  ILatLng copyWith({
    double latitude,
    double longitude,
    double bearing,
    MarkerId markerId,
    bool isStopover,
    bool ripple,
    bool isEmpty,
    double mapScale,
  });

  //Delta operator, this object represents the end position
  double operator -(ILatLng other);
}
