
import 'package:flutter/material.dart';

@immutable
abstract class  ILatLng {
  final double latitude = 0;
  final double longitude = 0;
  final double bearing = 0;
  final String markerId = "";
  final bool isStopover = false;
  final bool ripple = false;
  final bool isEmpty = false;

  ILatLng copyWith({
    double latitude,
    double longitude,
    double bearing,
    String markerId,
    bool isStopover,
    bool ripple,
    bool isEmpty,
  });


}