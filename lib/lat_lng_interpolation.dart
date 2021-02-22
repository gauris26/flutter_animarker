import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animarker/interpolation/linear_interpolation.dart';
import 'package:flutter_animarker/interpolation/rotation_interpolation.dart';
import 'helpers/spherical_util.dart';
import 'models/lat_lng_delta.dart';
import 'models/lat_lng_info.dart';

class LatLngInterpolationStream {

  Map<String, RotationInterpolation> _rotationInterpolations;
  Map<String, LinearInterpolation> _linearInterpolations;
  Map<String, StreamSubscription> _subscriptions;

  Curve curve;

  LatLngInterpolationStream({
    this.curve = Curves.linear,
    Duration rotationDuration,
    Duration rotationInterval,
    Duration movementDuration,
    Duration movementInterval,
  }) {

    _rotationInterpolations = Map<String, RotationInterpolation>();
    _linearInterpolations = Map<String, LinearInterpolation>();
    _subscriptions = Map<String, StreamSubscription>();
    /*_linearInterpolation = LinearInterpolation(
        movementDuration: movementDuration ?? Duration(milliseconds: 20000),
        movementInterval: movementInterval ?? Duration(milliseconds: 20),);*/

    /*_rotationInterpolation = RotationInterpolation(curve: curve,
        rotationDuration: rotationDuration ?? Duration(milliseconds: 600),
        rotationInterval: rotationInterval ?? Duration(milliseconds: 12),
    );*/
  }

  //Add Marker's LatLng for animation processing
  void addLatLng(LatLngInfo latLng) {
    debugPrint(latLng.toString());

    _linearInterpolations[latLng.markerId] ??= LinearInterpolation();
    _rotationInterpolations[latLng.markerId] ??= RotationInterpolation();

    _subscriptions[latLng.markerId] ??= _linearInterpolations[latLng.markerId].latLngLinearInterpolation().listen((v) {
      _rotationInterpolations[latLng.markerId].rotatePosition(v);
    });

    _linearInterpolations[latLng.markerId].addLatLng(latLng);
  }

  Stream<LatLngDelta> getAnimatedPosition([String markerId = ""]) {

    _linearInterpolations[markerId] ??= LinearInterpolation();
    _rotationInterpolations[markerId] ??= RotationInterpolation();

    return _rotationInterpolations[markerId].getRotationLatLngInterpolation();
  }

  void cancel() {
    _subscriptions?.forEach((key, value) => value?.cancel());
  }
}
