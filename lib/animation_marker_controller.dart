import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/interpolation/linear_interpolation.dart';
import 'package:flutter_animarker/interpolation/rotation_interpolation.dart';
import 'models/lat_lng_delta.dart';
import 'models/lat_lng_info.dart';

///Animation Marker Controller
class AnimarkerController {
  final _rotationInterpolations = Map<String, RotationInterpolation>();
  final _linearInterpolations = Map<String, LinearInterpolation>();
  final linearSubscriptionGroup = StreamGroup<LatLngDelta>();
  final rotationSubscriptionGroups = StreamGroup<LatLngDelta>();
  final Curve curve;

  AnimarkerController({this.curve = Curves.linear}) {
    linearSubscriptionGroup.stream.listen((v) {

      _rotationInterpolations[v?.markerId]?.rotatePosition(v);
    });
  }

  ///Push Marker's LatLng StopOver for animation processing
  void pushLatLng(LatLngInfo latLng) {

    //Add Linear Interpolation
    if (!_linearInterpolations.containsKey(latLng.markerId)) {
      _linearInterpolations[latLng.markerId] = LinearInterpolation();
      linearSubscriptionGroup
          .add(_linearInterpolations[latLng?.markerId]?.latLngLinearInterpolation());

    }

    //Add Rotation Interpolation
    if (!_rotationInterpolations.containsKey(latLng.markerId)) {
      _rotationInterpolations[latLng.markerId] = RotationInterpolation();
      rotationSubscriptionGroups
          .add(_rotationInterpolations[latLng.markerId]?.getRotationLatLngInterpolation());
    }

    _linearInterpolations[latLng.markerId]?.addLatLng(latLng);
  }

  Stream<LatLngDelta> getAnimatedPositions() => rotationSubscriptionGroups.stream;

  void close() async {
    await linearSubscriptionGroup.close();
    await rotationSubscriptionGroups.close();
    _linearInterpolations.forEach((key, value)  => value?.dispose());
    _rotationInterpolations.forEach((key, value)  => value?.dispose());
  }
}
