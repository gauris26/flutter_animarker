// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_animarker/models/lat_lng_info.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
abstract class  ILatLng {
  final double latitude = 0;
  final double longitude = 0;
  final double bearing = 0;
  final MarkerId markerId = const MarkerId('');
  final bool isStopover = false;
  final bool ripple = false;
  final bool isEmpty = false;
  final double mapScale = 1.0;

  const factory ILatLng.empty() = LatLngInfo.empty;

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
