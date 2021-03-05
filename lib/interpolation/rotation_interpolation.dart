import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/helpers/math_util.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_delta.dart';
import 'package:flutter_animarker/streams/lat_lng_delta_stream.dart';

@deprecated
class RotationInterpolation {
  Curve curve;
  CurveTween curveTween;
  Duration rotationDuration;
  Duration rotationInterval;
  LatLngDeltaStream _latLngRotationStream;

  RotationInterpolation({
    this.curve = Curves.linear,
    this.rotationDuration = const Duration(milliseconds: 500),
    this.rotationInterval = const Duration(milliseconds: 10),
  }) {
    _latLngRotationStream = LatLngDeltaStream();
    curveTween = CurveTween(curve: curve);
  }

  ///Rotate marker between two given delta position (End-Start)
  void rotatePosition(LatLngDelta latLng) {
    _latLngRotationStream.addLatLng(latLng);
  }

  Stream<LatLngDelta> getRotationLatLngInterpolation() async* {
    int start = 0; //To determine when the animation has ended
    double lastBearing = 0.0 / 0.0; //Creating a start position, since any value could be a valida angle

    //Waiting for new incoming LatLng movement
    await for (LatLngDelta deltaPosition in _latLngRotationStream.stream) {

      double angle = SphericalUtil.angleShortestDistance(
        MathUtil.toRadians(lastBearing),
        MathUtil.toRadians(deltaPosition.rotation),
      );

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
      //Saving the current angle
      double currentAngle = deltaPosition.rotation;
      //Saving the last angle for rotation animation
      double lastAngle = lastBearing;

      //Iterate meanwhile the rotation duration hasn't completed
      //When the elapsed is equal to the durationRotation the animation is over
      while (elapsed.toDouble() / rotationDuration.inMilliseconds < 1.0) {

        elapsed = DateTime.now().millisecondsSinceEpoch - start;

        double rotation = _lerp(elapsed, lastAngle, currentAngle);

        //Save previous angle position
        lastBearing = deltaPosition.rotation;

        deltaPosition.rotation = rotation;

        yield deltaPosition;

        await Future.delayed(rotationInterval);
      }
    }
  }

  double _lerp(int elapsed, double lastAngle, double currentAngle){

    double t = (elapsed.toDouble() / rotationDuration.inMilliseconds).clamp(0.0, 1.0);

    //Value of the curve at point `t`;
    double value = curveTween.transform(t);

    double rotationAngle = SphericalUtil.angleLerp(lastAngle, currentAngle, value);

    return rotationAngle;
  }

  void dispose() {
  _latLngRotationStream.dispose();
}
}
