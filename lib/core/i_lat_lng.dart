
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
abstract class  ILatLng {
  final double latitude = 0;
  final double longitude = 0;
  final double bearing = 0;
  final MarkerId? markerId = MarkerId('');
  final bool isStopover = false;
  final bool ripple = false;
  final bool isEmpty = false;
  final double mapScale = 1.0;

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


}