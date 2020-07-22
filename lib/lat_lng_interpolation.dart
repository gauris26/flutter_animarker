import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import 'helpers/math_util.dart';
import 'helpers/spherical_util.dart';
import 'models/lat_lng_delta.dart';
import 'streams/lat_lng_delta_stream.dart';
import 'streams/lat_lng_stream.dart';

class LatLngInterpolationStream {
  LatLngStream _latLngStream;
  LatLngDeltaStream _latLngRotationStream;
  Duration movementDuration;
  Duration rotationDuration;
  Duration movementInterval;
  Duration rotationInterval;
  LatLng previousLatLng;
  LatLng lastInterpolatedPosition;
  StreamSubscription subscription;
  Curve curve;

  LatLngInterpolationStream({
    this.curve = Curves.linear,
    this.rotationDuration = const Duration(milliseconds: 600),
    this.movementDuration = const Duration(milliseconds: 1000),
    this.movementInterval = const Duration(milliseconds: 20),
    this.rotationInterval = const Duration(milliseconds: 12),
  }) {
    _latLngStream = LatLngStream();
    _latLngRotationStream = LatLngDeltaStream();
  }

  //Add Marker's LatLng for animation processing
  void addLatLng(LatLng latLng) {
    if (subscription == null) {
      subscription =
          _latLngMovementInterpolation().listen((v) => _rotateLatLng(v));
    }
    _latLngStream.addLatLng(latLng);
  }

  ///Rotate markers between two given position
  void _rotateLatLng(LatLngDelta latLng) {
    _latLngRotationStream.addLatLng(latLng);
  }

  Stream<LatLngDelta> getLatLngInterpolation() async* {
    int start = 0; //To determine when the animation has ended
    double lastBearing = 0.0 /
        0.0; //Creation a start position, since any value could be a valida angle
    CurveTween curveTween = CurveTween(curve: curve);

    //Waiting for new incoming LatLng movement
    await for (LatLngDelta deltaPosition in _latLngRotationStream.stream) {
      double angle = SphericalUtil.angleShortestDistance(
          MathUtil.toRadians(lastBearing),
          MathUtil.toRadians(deltaPosition.rotation));
      double angleDelta = MathUtil.toDegrees(angle);

      //No taking angle movement below 25.0 degrees
      if (lastBearing.isNaN || angleDelta.abs() < 25.0) {
        //Saving the position for calculate angle delta
        lastBearing = deltaPosition.rotation;
        //Send the same delta position to the stream buffer, any changes detected
        yield deltaPosition;
        continue;
      }

      //Saving the time in millisecond when the animation start, and calculate the elapsed time
      start = DateTime.now().millisecondsSinceEpoch;
      int elapsed = 0;
      double currentAngle = deltaPosition.rotation;
      //Saving the last angle for rotation animation
      double lastAngle = lastBearing;

      //Iterate meanwhile the rotation duration hasn't completed
      //When the elapsed is equal to the durationRotation the animation is over
      while (elapsed.toDouble() / rotationDuration.inMilliseconds < 1.0) {
        elapsed = DateTime.now().millisecondsSinceEpoch - start;

        double t = (elapsed.toDouble() / rotationDuration.inMilliseconds)
            .clamp(0.0, 1.0);

        //Value of the curve at point `t`;
        double value = curveTween.transform(t);

        double rotation =
            SphericalUtil.angleLerp(lastAngle, currentAngle, value);

        lastBearing = deltaPosition.rotation;
        deltaPosition.rotation = rotation;

        yield deltaPosition;

        await Future.delayed(rotationInterval);
      }
    }
  }

  ///Interpolate just the linear movement of the markers
  Stream<LatLngDelta> _latLngMovementInterpolation() async* {
    double lastBearing = 0;
    int start = 0;

    await for (LatLng pos in _latLngStream.stream) {
      double distance =
          SphericalUtil.computeDistanceBetween(previousLatLng ?? pos, pos);

      //First marker, required at least two from have a delta position
      if (previousLatLng == null || distance < 5.5) {
        previousLatLng = pos;
        continue;
      }

      CurveTween curveTween = CurveTween(curve: curve);

      start = DateTime.now().millisecondsSinceEpoch;
      int elapsed = 0;

      while (elapsed.toDouble() / movementDuration.inMilliseconds < 1.0) {
        elapsed = DateTime.now().millisecondsSinceEpoch - start;

        double t = (elapsed.toDouble() / movementDuration.inMilliseconds).clamp(0.0, 1.0);

        //Value of the curve at point `t`;
        double value = curveTween.transform(t);
        
        LatLng latLng = SphericalUtil.interpolate(previousLatLng, pos, t);

        double rotation = SphericalUtil.getBearing(
            latLng, lastInterpolatedPosition ?? previousLatLng);

        double diff =
            SphericalUtil.angleShortestDistance(rotation, lastBearing);

        double distance = SphericalUtil.computeDistanceBetween(
            latLng, lastInterpolatedPosition ?? previousLatLng);

        //Determine if the marker's has made a significantly movement
        if (diff.isNaN || distance < 1.5) {
          continue;
        }

        yield LatLngDelta(
          from: lastInterpolatedPosition ?? previousLatLng,
          to: latLng,
          rotation: !rotation.isNaN ? rotation : lastBearing,
        );

        lastBearing = !rotation.isNaN ? rotation : lastBearing;

        lastInterpolatedPosition = latLng;

        await Future.delayed(movementInterval);
      }
      previousLatLng = lastInterpolatedPosition;
    }
  }

  void cancel() {
    subscription.cancel();
  }
}
